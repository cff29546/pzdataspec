import argparse
import os
import sys


RELEASE_DIR = os.path.normpath(os.path.join(os.path.dirname(__file__), '..', 'output', 'release'))
sys.path.append(RELEASE_DIR)

from pzdataspec import parser
from pzdataspec.utils import (
    decode_str_value,
    load_chunk,
    load_conf,
    locatete_world_dict,
)


WORLD_DICT_B41 = parser.Parser('world_dictionary', version=195)
WORLD_DICT = parser.Parser('world_dictionary', version='latest')


def resolve_item_name(registry_id, mapping):
    return mapping.get(registry_id, f'id:{registry_id}')


def stats(name, value):
    print('{}: {}'.format(name, value))


def load_world_dict_items(path, version=None):
    if not path:
        return {}
    if version == 41:
        wd = WORLD_DICT_B41.parse_file(path)
    else:
        wd = WORLD_DICT.parse_file(path)

    modules = [decode_str_value(m).strip() for m in getattr(wd, 'modules', [])]
    item_map = {}
    for entry in getattr(wd, 'items', []):
        item_id = int(entry.registry_id)
        item_name = decode_str_value(entry.name).strip()
        module_index = int(entry.module_index)
        if 0 <= module_index < len(modules):
            item_map[item_id] = '{}.{}'.format(modules[module_index], item_name)
        else:
            item_map[item_id] = item_name
    return item_map


def parse_group_items(group):
    identical = int(group.identical)
    item_warp = group.item.data
    registry_id = int(item_warp.registry_id)
    save_type = int(item_warp.save_type)

    main_item = item_warp.item
    first_id = int(getattr(main_item, 'id', -1))
    duplicate_ids = [int(item_id) for item_id in getattr(group, 'duplicate_ids', [])]
    all_ids = [first_id] + duplicate_ids

    out = []
    for idx in range(identical):
        item_id = all_ids[idx] if idx < len(all_ids) else first_id
        out.append({
            'registry_id': registry_id,
            'item_id': item_id,
            'save_type': save_type,
        })
    return out


def extract_container_items(container):
    compressed = getattr(container, 'items', None)
    if compressed is None:
        return []

    items = []
    for group in getattr(compressed, 'item_groups', []):
        items.extend(parse_group_items(group))
    return items


def extract_world_item(item_blob):
    if item_blob is None:
        return []
    item_warp = item_blob.data
    main_item = item_warp.item
    return [{
        'registry_id': int(item_warp.registry_id),
        'item_id': int(getattr(main_item, 'id', -1)),
        'save_type': int(item_warp.save_type),
    }]


def iter_grid_squares(chunk):
    for idx, square in enumerate(chunk.raw.squares):
        x, y = divmod(idx, chunk.block_size)

        layer = chunk.min_layer
        bit = chunk.min_layer_bit
        for grid_square in square.squares:
            while layer < chunk.max_layer and (int(square.layer_flags) & bit) == 0:
                bit <<= 1
                layer += 1

            yield layer, x, y, grid_square
            bit <<= 1
            layer += 1


def iter_records(chunk):
    for layer, x, y, grid_square in iter_grid_squares(chunk):
        for object_index, obj_wrap in enumerate(getattr(grid_square, 'objects', [])):
            obj = obj_wrap.object
            class_id = int(getattr(obj, 'class_id', -1))

            base = getattr(obj, 'base_object', None)
            extra_data = getattr(base, 'extra_data', None) if base is not None else None
            if extra_data is not None and int(getattr(extra_data, 'num_containers', 0)) > 0:
                for container_index, container in enumerate(extra_data.containers):
                    yield {
                        'kind': 'container',
                        'path': 'base.extra_data.containers',
                        'container_index': container_index,
                        'container_type': decode_str_value(getattr(container, 'type_name', '')).strip(),
                        'items': extract_container_items(container),
                        'class_id': class_id,
                        'object_index': object_index,
                        'layer': layer,
                        'x': x,
                        'y': y,
                    }

            subclass = getattr(obj, 'subclass_object', None)
            if subclass is None:
                continue

            container = getattr(subclass, 'container', None)
            if container is not None and hasattr(container, 'items'):
                yield {
                    'kind': 'container',
                    'path': 'subclass.container',
                    'container_index': 0,
                    'container_type': decode_str_value(getattr(container, 'type_name', '')).strip(),
                    'items': extract_container_items(container),
                    'class_id': class_id,
                    'object_index': object_index,
                    'layer': layer,
                    'x': x,
                    'y': y,
                }

            container_data = getattr(subclass, 'container_data', None)
            if container_data is not None:
                sub_container = getattr(container_data, 'container', None)
                if sub_container is not None:
                    yield {
                        'kind': 'container',
                        'path': 'subclass.container_data.container',
                        'container_index': 0,
                        'container_type': decode_str_value(getattr(sub_container, 'type_name', '')).strip(),
                        'items': extract_container_items(sub_container),
                        'class_id': class_id,
                        'object_index': object_index,
                        'layer': layer,
                        'x': x,
                        'y': y,
                    }

            inventory = getattr(subclass, 'inventory', None)
            if inventory is not None and hasattr(inventory, 'items'):
                yield {
                    'kind': 'container',
                    'path': 'subclass.inventory',
                    'container_index': 0,
                    'container_type': decode_str_value(getattr(inventory, 'type_name', '')).strip(),
                    'items': extract_container_items(inventory),
                    'class_id': class_id,
                    'object_index': object_index,
                    'layer': layer,
                    'x': x,
                    'y': y,
                }

            world_item_blob = getattr(subclass, 'item', None)
            if world_item_blob is not None and hasattr(world_item_blob, 'data'):
                yield {
                    'kind': 'world_item',
                    'path': 'subclass.item',
                    'container_index': 0,
                    'container_type': 'world_item',
                    'items': extract_world_item(world_item_blob),
                    'class_id': class_id,
                    'object_index': object_index,
                    'layer': layer,
                    'x': x,
                    'y': y,
                }


def print_record(record, item_names, show_empty=False):
    items = record['items']
    if not show_empty and not items:
        return 0

    print(
        'L{layer} {x},{y} obj#{obj} class:{cid} src:{src} type:{typ} items:{num}'.format(
            layer=record['layer'],
            x=record['x'],
            y=record['y'],
            obj=record['object_index'],
            cid=record['class_id'],
            src=record['path'],
            typ=record['container_type'] or '-',
            num=len(items),
        )
    )

    for item in items:
        item_name = resolve_item_name(item['registry_id'], item_names)
        print(
            '  - item_id:{item_id} registry:{registry_id} save_type:{save_type} name:{name}'.format(
                item_id=item['item_id'],
                registry_id=item['registry_id'],
                save_type=item['save_type'],
                name=item_name,
            )
        )
    return 1


def main():
    parser_ = argparse.ArgumentParser(description='Extract items and containers from a chunk file')
    parser_.add_argument('file', help='Path to the chunk file')
    parser_.add_argument('-c', '--conf', help='Path to the config file (optional)', default=None)
    parser_.add_argument('-w', '--world-dict', help='Path to WorldDictionary.bin (optional)', default=None)
    parser_.add_argument('-se', '--show-empty', action='store_true', help='Show containers even when they have zero items')
    args = parser_.parse_args()

    conf = {}
    if args.conf:
        conf = load_conf(args.conf)

    chunk = load_chunk(args.file)
    version = 41 if int(chunk.raw.world_version) <= 195 else 42

    world_dict = args.world_dict or conf.get('WORLD_DICT', None) or locatete_world_dict(args.file)
    item_names = load_world_dict_items(world_dict, version)

    stats('chunk world version', int(chunk.raw.world_version))
    stats('world dictionary path', world_dict or 'N/A')
    stats('world dictionary items', len(item_names))

    printed = 0
    for record in iter_records(chunk):
        printed += print_record(record, item_names, args.show_empty)

    stats('records printed', printed)


if __name__ == '__main__':
    main()