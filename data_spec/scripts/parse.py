
import sys
import os
import importlib
from kaitaistruct import KaitaiStream, BytesIO
from kaitaistruct import KaitaiStruct
from kaitaistruct import __version__ as ks_version

def dump_data(data, path):
    with open(path, 'wb') as f:
        f.write(data)

def parse_ktable(data):
    result = {}
    for entry in data.entries:
        key = entry.key.value
        value = entry.value.value
        result[get_value(key)] = get_value(value)
    return result

def get_value(value):
    data_type = type(value).__name__
    if data_type == 'StringUtf':
        return value.value
    if data_type == 'Ktable':
        return parse_ktable(value)
    if data_type == 'SizedBlob':
        return len(value.data)
    return value

def display(field, value, indent=0):
    output = []
    prefix = ' ' * indent
    data_type = type(value).__name__
    if isinstance(value, list):
        length = len(value)
        data_type = ''
        if length > 0:
            data_type = type(value[0]).__name__
        output.append(f"{prefix}{field}: {data_type}[{length}]")
    elif isinstance(value, str) or isinstance(value, bytes):
        length = len(value)
        if length > 40:
            output.append(f"{prefix}{field}: {data_type}:{value[:40]}...")
        else:
            output.append(f"{prefix}{field}: {data_type}:{value}")
    else:
        value = get_value(value)
        output.append(f"{prefix}{field}: {data_type}:{value}")
    return output

def brief(data):
    output = []
    for field in dir(data):
        if field.startswith('_'):
            continue
        value = getattr(data, field)
        if callable(value):
            continue
        output.extend(display(field, value))
    return output

def detail(data, indent=0, field='', output=None):
    if output is None:
        output = []
    prefix = ' ' * indent
    data_type = type(data).__name__
    if isinstance(data, list):
        length = len(data)
        data_type = ''
        if length > 0:
            data_type = type(data[0]).__name__
        output.append(f"{prefix}{field}: {data_type}[{length}]")
        for i, item in enumerate(data):
            output.append(f"{prefix}  - [{i}]: {data_type}")
            detail(item, indent + 4, '', output)
        return output
    if data_type == 'Ktable':
        output.append(f"{prefix}{field}: Ktable")
        ktable = parse_ktable(data)
        output.extend(display_dict(ktable, indent + 4))
        return output
    if isinstance(data, KaitaiStruct):
        for key in dir(data):
            if key.startswith('_'):
                continue
            value = getattr(data, key)
            if callable(value):
                continue
            data_type = type(value).__name__
            output.append(f"{prefix}{key}: {data_type}")
            detail(value, indent + 4, '', output)
    else:
        if len(output):
            output[-1] += f" = {get_value(data)}"
        else:
            output.append(f"= {get_value(data)}")
    return output

def display_dict(d, indent=0):
    output = []
    prefix = ' ' * indent
    for key, value in d.items():
        if isinstance(value, dict):
            output.append(f"{prefix}{key}: Ktable")
            output.extend(display_dict(value, indent + 4))
        else:
            output.extend(display(key, value, indent))
    return output

def print_lotpack(data):
    output = []
    for block in data.blocks:  # Limit to first 10 blocks for brevity
        elements = 0
        skip = 0
        for i, element in enumerate(block.data.elements):
            if element.is_skip:
                skip += element.skip_count
            else:
                elements += 1
        total = elements + skip
        output.append(f"Block: {block.index:<4} Offset: {block.offset:<7} Length: {block.len_data:<5} Elements: {elements:<3}/{total}")
    return output

def snake_to_pascal(name):
    return ''.join(word.capitalize() for word in name.split('_'))

def load_spec(schema_name, lib_path=None):
    if lib_path is None:
        lib_path = os.path.abspath(os.path.join(os.path.dirname(__file__), '../../output/spec'))
    sys.path.append(lib_path)
    SchemaModule = importlib.import_module(schema_name)
    Schema = getattr(SchemaModule, snake_to_pascal(schema_name))
    return Schema

if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser(description="Parse binary files using a Kaitai Struct schema and output results in a human-readable format.")
    parser.add_argument('-o', '--output', type=str, help='Output file to write results to', default=None)
    parser.add_argument('-d', '--dump-field', type=str, default=None, help='Field to dump binary data from')
    parser.add_argument('-do', '--dump-output', type=str, default='output/dump.bin', help='Output path for dumped binary data')
    parser.add_argument('-nv', '--no-verbose', action='store_true', help='Disable verbose output')
    parser.add_argument('-l', '--lib-path', type=str, default=None, help='Path to the generated parser library')
    parser.add_argument("--params", default="", help="Comma-separated root params (numbers or strings)")
    parser.add_argument('schema', type=str, help='Path to the schema name (not including .ksy)')
    parser.add_argument('files', metavar='F', type=str, nargs='+')
    args = parser.parse_args()

    # Dynamically import the schema module
    Schema = load_spec(args.schema, lib_path=args.lib_path)

    if Schema is None:
        print("Could not find schema [{}]".format(args.schema))
        sys.exit(1)

    params = []
    if args.params.strip():
        for raw in args.params.split(','):
            token = raw.strip()
            if token == '':
                continue
            if token.isdigit() or (token.startswith('-') and token[1:].isdigit()):
                params.append(int(token))
            else:
                params.append(token)

    data = []
    d = None
    output = []
    for fn in args.files:
        if not args.no_verbose:
            print("Parsing file: {}".format(fn))
        with open(fn, 'rb') as f:
            io = KaitaiStream(BytesIO(f.read()))
            d = Schema(*params, io)

            func = globals().get('print_' + args.schema)
            if func is None:
                func = detail if args.output else brief
            if args.dump_field and hasattr(d, args.dump_field):
                bin_data = getattr(d, args.dump_field)
                if isinstance(bin_data, bytes):
                    dump_data(bin_data, args.dump_output)
                    print(f"Dumped field '{args.dump_field}' to {args.dump_output}")
            output_lines = func(d)
            output.extend(output_lines + [''])

    if args.output:
        with open(args.output, 'w', encoding='utf-8') as out_file:
            out_file.write('\n'.join(output + ['']))
    else:
        for line in output:
            print(line)