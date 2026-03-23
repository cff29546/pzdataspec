import importlib
import sys
import os
from kaitaistruct import KaitaiStream, BytesIO

def snake_to_pascal(snake_str):
    components = snake_str.split('_')
    return ''.join(x.title() for x in components)


def import_spec_module(schema_name, version=None):
    path_parts = [os.path.dirname(__file__), 'spec']
    spec_path = os.path.normpath(os.path.join(*path_parts))
    path_added = False
    if spec_path not in sys.path:
        sys.path.insert(0, spec_path)
        path_added = True
    schema = importlib.import_module(f".{schema_name}", package=f"v{version}")
    if path_added:
        sys.path.remove(spec_path)
    return schema

def exists_version(version):
    spec_path = os.path.normpath(os.path.join(os.path.dirname(__file__), 'spec', f'v{version}'))
    return os.path.isdir(spec_path)

def get_all_versions():
    spec_dir = os.path.normpath(os.path.join(os.path.dirname(__file__), 'spec'))
    versions = [d[1:] for d in os.listdir(spec_dir) if os.path.isdir(os.path.join(spec_dir, d)) and d.startswith('v') and d[1:].isdigit()]
    return sorted(versions, key=int)

def get_latest_version():
    versions = get_all_versions()
    return max(versions) if versions else None

def load_spec(schema_name, version=None):
    if not exists_version(version) or version == 'latest':
        version = get_latest_version()
    SchemaModule = import_spec_module(schema_name, version)
    Schema = getattr(SchemaModule, snake_to_pascal(schema_name))
    return Schema

class Parser(object):
    def __init__(self, schema_name, schema_args=None, version=None):
        self.schema = load_spec(schema_name, version)
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