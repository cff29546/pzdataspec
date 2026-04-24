import sqlite3
import argparse
import sys
import os
import importlib
from kaitaistruct import KaitaiStream, BytesIO
from kaitaistruct import __version__ as ks_version
from parse import brief, detail, dump_data, snake_to_pascal, load_spec

def query_data(path, table, fields):
    conn = sqlite3.connect(path)
    cursor = conn.cursor()
    cursor.execute(f"SELECT {', '.join(fields)} FROM {table}")
    rows = cursor.fetchall()
    conn.close()
    return rows

def process(schema, rows, print_func=brief, dump_path=None):
    output = []
    try:
        for row in rows:
            data = row[0]
            args = list(row[1:])
            output.append(f'{len(data)} {args}')
            io = KaitaiStream(BytesIO(data))
            args.append(io)
            data = schema(*args)
            output.extend(print_func(data))
    except Exception as e:
        output.append(f"Error processing row: len={len(data)}, args={args}")
        output.append(f"Exception: {e}")
        if dump_path:
            dump_file = os.path.join(dump_path, f'error_row.bin')
            dump_data(data, dump_file)
        raise e
    return output

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Parse database files.")
    parser.add_argument('schema', type=str, help='Path to the schema name (not including .ksy)')
    parser.add_argument('db', type=str, help='Path to the database file')
    parser.add_argument('table', type=str, help='Table name to query')
    parser.add_argument('-o', '--output', type=str, help='Output file to write results to', default=None)
    parser.add_argument('-d', '--data-field', type=str, default='data', help='Field name containing binary data')
    parser.add_argument('-a', '--arg-fields', type=str, default='', help='Additional fields to retrieve (comma-separated)')
    parser.add_argument('-e', '--extra-args', type=str, default='', help='Comma-separated constant params appended after SQL arg fields (numbers or strings)')
    parser.add_argument('-D', '--dump-path', type=str, default=None, help='Directory to dump error data')
    args = parser.parse_args()

    fields = [args.data_field]
    if args.arg_fields:
        fields.extend(args.arg_fields.split(','))
    rows = query_data(args.db, args.table, fields)

    extra_args = []
    if args.extra_args.strip():
        for raw in args.extra_args.split(','):
            token = raw.strip()
            if token == '':
                continue
            if token.lstrip('-').isdigit():
                extra_args.append(int(token))
            else:
                extra_args.append(token)
    if extra_args:
        rows = [tuple(list(r) + extra_args) for r in rows]

    # Dynamically import the schema module
    Schema = load_spec(args.schema)

    if Schema is None:
        print("Could not find schema [{}]".format(args.schema))
        sys.exit(1)

    output = process(Schema, rows, detail if args.output else brief, args.dump_path)
    if args.output:
        with open(args.output, 'w', encoding='utf-8') as out_file:
            out_file.write('\n'.join(output + ['']))
    else:
        for line in output:
            print(line)
