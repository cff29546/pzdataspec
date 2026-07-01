import argparse
import os
import sys


RELEASE_DIR = os.path.normpath(os.path.join(os.path.dirname(__file__), '..', 'output', 'release'))
sys.path.append(RELEASE_DIR)

from pzdataspec.scripts.items import get_items, get_items_name2type
from pzdataspec.utils import (
    load_conf,
    build_context,
    locatete_world_dict,
)


def stats(name, value):
    print('{}: {}'.format(name, value))


def resolve_world_dict(input_path, conf):
    if input_path and os.path.isfile(input_path):
        if os.path.basename(input_path).lower() == 'worlddictionary.bin':
            return os.path.normpath(input_path)
        return locatete_world_dict(input_path)

    from_conf = conf.get('WORLD_DICT', None)
    if from_conf and os.path.isfile(from_conf):
        return os.path.normpath(from_conf)
    return None


def resolve_scripts_dir(explicit_scripts_dir, conf):
    if explicit_scripts_dir:
        return os.path.normpath(explicit_scripts_dir)

    from_conf = conf.get('SCRIPTS_DIR', None)
    if from_conf:
        return os.path.normpath(from_conf)

    pz_root = conf.get('PZ_ROOT', None)
    if pz_root:
        return os.path.normpath(os.path.join(pz_root, 'media', 'scripts'))

    return None


def pick_version(value):
    if value == '41':
        return 41
    if value == '42':
        return 42
    return None


def parse_ids(raw_ids):
    if not raw_ids:
        return []
    ids = []
    for part in raw_ids.split(','):
        part = part.strip()
        if not part:
            continue
        ids.append(int(part))
    return ids


def main():
    parser_ = argparse.ArgumentParser(
        description='Test item id->name and id->item_type utility mappings'
    )
    parser_.add_argument(
        'input',
        nargs='?',
        default=None,
        help='Path to WorldDictionary.bin or a chunk file (optional)',
    )
    parser_.add_argument('-c', '--conf', help='Path to config file (optional)', default=None)
    parser_.add_argument('-w', '--world-dict', help='Path to WorldDictionary.bin (optional)', default=None)
    parser_.add_argument('-s', '--scripts-dir', help='Path to media/scripts directory (optional)', default=None)
    parser_.add_argument('-t', '--types', action='store_true', help='Print all possible item types', default=False)
    parser_.add_argument(
        '-v',
        '--version',
        choices=['auto', '41', '42'],
        default='auto',
        help='World dictionary format version',
    )
    parser_.add_argument(
        '-i',
        '--ids',
        default='',
        help='Comma-separated registry ids to inspect (example: 10,20,999)',
    )
    parser_.add_argument(
        '-n',
        '--sample-size',
        type=int,
        default=0,
        help='Number of entries to print when no --ids are provided',
    )
    args = parser_.parse_args()

    conf = load_conf(args.conf) if args.conf else {}
    pz_root = conf.get('PZ_ROOT', None)

    world_dict_path = args.world_dict or resolve_world_dict(args.input, conf)
    save_root = os.path.dirname(world_dict_path) if world_dict_path else None
    version = pick_version(args.version)

    context = build_context(save_root, pz_root, version)
    id_to_type = context['item_id_to_type']
    id_to_name = context['item_id_to_name']

    stats('world dictionary path', world_dict_path)
    stats('pz root', pz_root)
    stats('version override', args.version)
    stats('id->name count', len(id_to_name))
    stats('id->type via util count', len(id_to_type))

    ids = parse_ids(args.ids)
    if not ids:
        ids = sorted(id_to_name.keys())[: max(0, int(args.sample_size))]

    if ids:
        print('Sample lookups:')
        for item_id in ids:
            item_name = id_to_name.get(item_id)
            item_type = id_to_type.get(item_id)
            print(
                '  - id:{} name:{} type:{}'.format(
                    item_id,
                    item_name if item_name is not None else 'N/A',
                    item_type if item_type is not None else 'N/A',
                )
            )

    if args.types:
        print('All possible item types:')
        all_types = sorted(set(id_to_type.values()))
        for item_type in all_types:
            print('  - {}'.format(item_type))

if __name__ == '__main__':
    main()
