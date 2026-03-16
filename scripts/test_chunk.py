import argparse
import sys
import os
RELEASE_DIR = os.path.normpath(os.path.join(os.path.dirname(__file__), '..', 'output', 'release'))
sys.path.append(RELEASE_DIR)
from pzdataspec.utils import (
    load_chunk,
    load_conf,
    load_tile_defs,
    load_world_dict,
    locatete_world_dict,
)


def resolve_sprite_name(sprite_id, mapping):
    return mapping.get(sprite_id, f'id:{sprite_id}')


def stats(mapping, name):
    print(f'{name} has {len(mapping)} entries')


def main():
    parser = argparse.ArgumentParser(description='Parse a chunk file')
    parser.add_argument('file', help='Path to the chunk file')
    parser.add_argument('-c', '--conf', help='Path to the config file (optional)', default=None)
    parser.add_argument('-p', '--pz-root', help='Path to the Project Zomboid root directory (optional)', default=None)
    parser.add_argument('-m', '--mod-root', help='Path to the Project Zomboid mod directory (optional)', default=None)
    parser.add_argument('--no-mods', action='store_true', help='Ignore mods when loading tile definitions')
    parser.add_argument('-v', '--version', default='42', help='Project Zomboid version for tile definitions (default: 42)')
    args = parser.parse_args()

    conf = {}
    if args.conf:
        conf = load_conf(args.conf)
    pz_root = conf.get('PZ_ROOT', None)
    mod_root = conf.get('MOD_ROOT', None)
    if args.pz_root:
        pz_root = args.pz_root
    if args.mod_root:
        mod_root = args.mod_root
    if args.no_mods:
        mod_root = None
    if not pz_root:
        print('Project Zomboid root directory not specified. Use -p or set pz_root in config.')
        raise SystemExit(1)

    tile_defs = load_tile_defs(pz_root, mod_root, args.version)
    stats(tile_defs, 'Tile definitions')
    world_sprites = load_world_dict(locatete_world_dict(args.file))
    stats(world_sprites, 'World dictionary')
    tile_defs.update(world_sprites)
    chunk = load_chunk(args.file)

    for l in range(chunk.min_layer, chunk.max_layer):
        layer = chunk.get_layer(l)
        if not layer:
            continue
        for x in range(len(layer)):
            if not layer[x]:
                continue
            for y in range(len(layer[x])):
                if not layer[x][y]:
                    continue
                names = [resolve_sprite_name(sprite_id, tile_defs) for sprite_id in layer[x][y]]
                print(f'{l} {x},{y}: {",".join(names)}')


if __name__ == '__main__':
    main()
