import importlib
import sys
import os
from kaitaistruct import KaitaiStream, BytesIO

def snake_to_pascal(snake_str):
    components = snake_str.split('_')
    return ''.join(x.title() for x in components)


def import_spec_module(schema_name):
    spec_path = os.path.normpath(os.path.join(os.path.dirname(__file__), 'spec'))
    path_added = False
    if spec_path not in sys.path:
        sys.path.append(spec_path)
        path_added = True
    schema = importlib.import_module(schema_name)
    if path_added:
        sys.path.remove(spec_path)
    return schema

def load_spec(schema_name):
    SchemaModule = import_spec_module(schema_name)
    Schema = getattr(SchemaModule, snake_to_pascal(schema_name))
    return Schema

class Parser(object):
    def __init__(self, schema_name, schema_args=None):
        self.schema = load_spec(schema_name)
        self.schema_args = schema_args

    def parse_data(self, data):
        if self.schema_args:
            return self.schema(*self.schema_args, KaitaiStream(BytesIO(data)))
        else:
            return self.schema(KaitaiStream(BytesIO(data)))
    
    def parse_file(self, file_path):
        with open(file_path, "rb") as f:
            data = f.read()
        return self.parse_data(data)