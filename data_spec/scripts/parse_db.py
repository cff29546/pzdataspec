import sqlite3
import argparse
import sys
import os
import importlib
from kaitaistruct import KaitaiStream, BytesIO
from kaitaistruct import __version__ as ks_version
from parse import brief, detail, dump_data, snake_to_pascal, load_spec, parse_param


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
        for data, args in rows:
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


class SQLParam:
    def __init__(self, field):
        self.field = field
        self.position = None


def sql(expr):
    return SQLParam(expr)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Parse database files.")
    parser.add_argument('schema', type=str, help='Path to the schema name (not including .ksy)')
    parser.add_argument('db', type=str, help='Path to the database file')
    parser.add_argument('table', type=str, help='Table name to query')
    parser.add_argument('-o', '--output', type=str, help='Output file to write results to', default=None)
    parser.add_argument('-d', '--data-field', type=str, default='data', help='Field name containing binary data')
    parser.add_argument('-p', '--params', action='append', default=[], help='Root param in order; repeat for multiple params. Format: value (int or str) or type:value (e.g. -p float:3.14), use sql:field for sql args')
    parser.add_argument('-D', '--dump-path', type=str, default=None, help='Directory to dump error data')
    args = parser.parse_args()

    params = [parse_param(token, {'sql': sql}) for token in args.params]
    fields = [args.data_field]
    for param in params:
        if isinstance(param, SQLParam):
            param.position = len(fields)
            fields.append(param.field)
    raw_rows = query_data(args.db, args.table, fields)

    rows = []
    for row in raw_rows:
        data = row[0]
        row_args = []
        for param in params:
            if isinstance(param, SQLParam):
                row_args.append(row[param.position])
            else:
                row_args.append(param)
        rows.append((data, row_args))

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
