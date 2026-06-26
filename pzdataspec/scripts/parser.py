# parser for Project Zomboid scripts under `media/scripts` directory

import lark
import io

GRAMMAR = r'''
start: _def+

_def: key_def | obj_def | comment | value_line
obj_def: [ _type ] name_or_value "{" _def* "}"
value_line.0: value [ "," ] | [ value ] ","
comment: _block_comment | _line_comment
_block_comment: "/*" ( /([*](?!\/)|(\/(?![*]))|[^*\/])+/ | _block_comment )* "*/"
_line_comment: "//" /[^\n]*\n/

key_def.2: name "=" value [ "," ]
_type: [ _template ] type _space
_template: TEMPLATE _space
TEMPLATE: "template"
_space: WHITESPACE
type: _name
name: _name
name_or_value: _name | _value
value: _value
_value: /[^,{} \t\n]([^,{}\n]*[^,{} \t\n])?/
_name: /[0-9a-zA-Z_.!:-]+/


WHITESPACE: /\s+/
%ignore WHITESPACE
'''

META_KEY = '__meta__'

class ProcessTree(lark.visitors.Transformer):
    def comment(self, args):
        return lark.visitors.Discard

    def WHITESPACE(self, args):
        return lark.visitors.Discard

    def value(self, args):
        return str(args[0])

    def name(self, args):
        return str(args[0])

    def name_or_value(self, args):
        return str(args[0])

    def type(self, args):
        return ('type', str(args[0]))

    def TEMPLATE(self, args):
        return ('template',)

    def value_line(self, args):
        if args[0] is None:
            # Empty value line (bare comma)
            return lark.visitors.Discard
        return ('value_line', args[0])

    def key_def(self, args):
        return ('kv', args[0], args[1])

    def obj_def(self, args):
        o = { META_KEY: {} }
        name = ''
        for arg in args:
            if isinstance(arg, str):
                name = arg
            elif arg[0] == 'type':
                o[META_KEY]['type'] = arg[1]
            elif arg[0] == 'template':
                o[META_KEY]['is_template'] = True
            elif arg[0] == 'kv':
                k, v = arg[1], arg[2]
                if k in ['template', 'template!']:
                    o[META_KEY].setdefault(k, []).append(v)
                else:
                    update_dict(o, {k: v})
            elif arg[0] == 'obj':
                k, v = arg[1], arg[2]
                update_dict(o, {k: v})
            elif arg[0] == 'value_line':
                v = arg[1]
                o[META_KEY].setdefault('value_lines', []).append(v)
        return ('obj', name, o)

    def start(self, args):
        o = {}
        for arg in args:
            if arg[0] == 'obj':
                name = arg[1]
                o.setdefault(name, {})
                update_dict(o[name], arg[2])
        return o

def update_dict(d, u):
    # Recursively update dict d with dict u
    # Update policies: for key k in u:
    # - if k not in d: d[k] = u[k]
    # - if k in d and both d[k] and u[k] are dicts: update_dict(d[k], u[k])
    # - if k in d and both d[k] and u[k] are lists: d[k].extend(u[k])
    # - otherwise: d[k] = u[k]
    for k, v in u.items():
        if k in d:
            if isinstance(d[k], dict) and isinstance(v, dict):
                update_dict(d[k], v)
                continue
            if isinstance(d[k], list) and isinstance(v, list):
                d[k].extend(v)
                continue
        d[k] = v

_PARSER = lark.Lark(GRAMMAR)
def parse_file_raw(path):
    text = ''
    with io.open(path, 'r', encoding='utf8') as f:
        text = f.read()
    return ProcessTree().transform(_PARSER.parse(text))

def process(o, type_filter=None):
    modules = {}
    for name, m in o.items():
        if name == META_KEY:
            continue
        if not isinstance(m, dict):
            continue
        if m.get(META_KEY, {}).get('type') != 'module':
            continue
        module = modules.setdefault(name, {})
        for k, v in m.items():
            if k == META_KEY:
                continue
            if not isinstance(v, dict):
                continue
            object_type = v.get(META_KEY, {}).get('type', None)
            if type_filter and object_type not in type_filter:
                continue
            if object_type == 'template':
                print("Warning: {}.{} template with missing type".format(name, k))
                continue
            is_template = v.get(META_KEY, {}).get('is_template', False)
            target = module
            if is_template:
                target = module.setdefault('template', {})
            if object_type is not None:
                target = target.setdefault(object_type, {})
            # object_type is None indicates it is a non-typed object like "imports { ... }"
            # we directly put it in the module without an extra layer as its metadata
            target[k] = v
    return modules

def parse_file(path, type_filter=None):
    raw = parse_file_raw(path)
    processed = process(raw, type_filter)
    return processed

def items(path):
    return parse_file(path, type_filter=['item'])

def to_yaml(path, output):
    import yaml
    i = items(path)
    with io.open(output, 'w', encoding='utf8') as f:
        f.write(yaml.safe_dump(i, encoding=None, allow_unicode=True))

if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser(description="Convert a script file to YAML")
    parser.add_argument('input', help="Input script file")
    parser.add_argument('-o', '--output', help="Output YAML file", default=None)
    parser.add_argument('-t', '--type', help="Comma-separated list of types to include", default=None)
    args = parser.parse_args()

    types = args.type.split(',') if args.type else None
    i = parse_file(args.input, type_filter=types)
    if args.output:
        with io.open(args.output, 'w', encoding='utf8') as f:
            import yaml
            f.write(yaml.safe_dump(i, encoding=None, allow_unicode=True))
    else:
        print('{} items found in {}'.format(len(i), args.input))
