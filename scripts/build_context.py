import argparse
import sys
import os
import yaml
RELEASE_DIR = os.path.normpath(os.path.join(os.path.dirname(__file__), '..', 'output', 'release'))
sys.path.append(RELEASE_DIR)
from pzdataspec.utils import (
    load_conf,
    build_context,
)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Build context for save game data')
    parser.add_argument('save_path', help='Path to the save game data folder')
    parser.add_argument('-c', '--conf', help='Path to the config file (optional)', default=None)
    parser.add_argument('-v', '--version', default=42, type=int, help='Project Zomboid version (default: 42)')
    args = parser.parse_args()

    conf = {}
    if args.conf:
        conf = load_conf(args.conf)
    pz_root = conf.get('PZ_ROOT', None)
    if not pz_root:
        print('Project Zomboid root directory not specified. Use -p or set pz_root in config.')
        raise SystemExit(1)

    context = build_context(args.save_path, pz_root, args.version)
    context_path = os.path.join(args.save_path, '.context.yaml')
    with open(context_path, 'w') as f:
        yaml.dump(context, f)