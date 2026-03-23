import os
from . import parser

TileDef = parser.Parser("tile_def", version='latest')
Chunk_B41 = parser.Parser('chunk', version=195)
Chunk = parser.Parser('chunk', version='latest')
WorldDict_B41 = parser.Parser('world_dictionary', version=195)
WorldDict = parser.Parser('world_dictionary', version='latest')


def load_conf(path):
    conf = {}
    if not os.path.isfile(path):
        return conf
    with open(path, 'r') as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith('#'):
                continue
            if '=' in line:
                key, value = line.split('=', 1)
                conf[key.strip()] = value.strip()
    return conf


def decode_str_value(v, encoding='utf-8'):
    value = v.value if hasattr(v, 'value') else v
    if isinstance(value, bytes):
        return value.decode(encoding)
    return value


def update_tile_defs(defs, path, file_no=0):
    if not path:
        return
    if not os.path.isfile(path):
        return
    if file_no <= 0:
        # skip patches
        return
    #print(f"Loading tile definitions from {path} with file number {file_no} ...")
    index_offset = 512 * 512 * file_no
    page_size = 512
    if file_no == 1:
        index_offset = 110000
        page_size = 1000

    td = TileDef.parse_file(path)
    for sheet in td.tile_sheets:
        sheet_name = decode_str_value(sheet.name, 'utf-8').strip()
        sheet_no = int(sheet.tileset_number)
        for tile_idx in range(int(sheet.num_tiles)):
            sprite_id = index_offset + sheet_no * page_size + tile_idx
            defs[sprite_id] = f'{sheet_name}_{tile_idx}'


B41_TILES = [
    'tiledefinitions.tiles', # 0
    'newtiledefinitions.tiles', # 1
    'tiledefinitions_erosion.tiles', # 2
    'tiledefinitions_apcom.tiles', # 3
    'tiledefinitions_overlays.tiles', # 4
]
B42_TILES = [
    None,
    'newtiledefinitions.tiles', # 1
    'tiledefinitions_erosion.tiles', # 2
    None,
    'tiledefinitions_overlays.tiles', # 4
    'tiledefinitions_b42chunkcaching.tiles', # 5
]
def load_tile_defs(pz_root, mod_root=None, version=None):
    if not pz_root:
        return {}
    tile_defs = {}
    tile_root = os.path.join(pz_root, 'media')
    tile_sets = B41_TILES if version and int(version) == 41 else B42_TILES
    for idx, tile_set in enumerate(tile_sets):
        if tile_set:
            update_tile_defs(tile_defs, os.path.join(tile_root, tile_set), idx)
    if mod_root:
        load_mod_tile_defs(tile_defs, mod_root, version)
    return tile_defs


def parse_version_dir_name(name):
    parts = name.split('.')
    if not all([p.isdigit() for p in parts]):
        return None
    version = [int(p) for p in parts]
    version += [0, 0]
    return tuple(version[:2])


def find_best_version(mod_folder, target_version):
    best_version = None
    best_version_tuple = ()
    version_min = (int(target_version), 0)
    version_max = (int(target_version), 999)
    for name in os.listdir(mod_folder):
        version_tuple = parse_version_dir_name(name)
        if version_tuple is None:
            continue
        if version_tuple <= version_max and version_tuple >= version_min and version_tuple > best_version_tuple:
            best_version_tuple = version_tuple
            best_version = name
    return best_version


def locate_mod_infos(mod_root, version):
    mod_infos = []
    for mod_id in os.listdir(mod_root):
        mod_dir = os.path.join(mod_root, mod_id, 'mods')
        if not os.path.isdir(mod_dir):
            continue
        for mod_name in os.listdir(mod_dir):
            mod_folder = os.path.join(mod_dir, mod_name)
            if not os.path.isdir(mod_folder):
                continue
            mod_info = os.path.join(mod_folder, 'mod.info')
            if os.path.isfile(mod_info):
                mod_infos.append(mod_info)
            mod_info = os.path.join(mod_folder, 'common', 'mod.info')
            if os.path.isfile(mod_info):
                mod_infos.append(mod_info)
            ver = find_best_version(mod_folder, version)
            if ver:
                mod_info = os.path.join(mod_folder, ver, 'mod.info')
                if os.path.isfile(mod_info):
                    mod_infos.append(mod_info)
    return mod_infos


def get_mod_tiledef(mod_info_path):
    mod_info = load_conf(mod_info_path)
    if not 'tiledef' in mod_info:
        return None, None
    
    parts = mod_info['tiledef'].split()
    tiledef_name = parts[0].strip()
    file_no = parts[1].strip()
    file_no = int(file_no) if file_no.isdigit() else None
    if not file_no:
        return None, None

    tiledef_path = os.path.join(os.path.dirname(mod_info_path), 'media', tiledef_name + '.tiles')
    if os.path.isfile(tiledef_path):
        return os.path.normpath(tiledef_path), file_no
    
    tiledef_path = os.path.join(os.path.dirname(mod_info_path), '..', 'media', tiledef_name + '.tiles')
    if os.path.isfile(tiledef_path):
        return os.path.normpath(tiledef_path), file_no

    tiledef_path = os.path.join(os.path.dirname(mod_info_path), '..', 'common', 'media', tiledef_name + '.tiles')
    if os.path.isfile(tiledef_path):
        return os.path.normpath(tiledef_path), file_no

    return None, None


def load_mod_tile_defs(defs, mod_root, version):
    if not mod_root or not os.path.isdir(mod_root):
        return

    file_no_map = {}
    for mod_info_path in locate_mod_infos(mod_root, version):
        tiledef_path, file_no = get_mod_tiledef(mod_info_path)
        if not tiledef_path:
            continue
        if file_no in file_no_map:
            #if tiledef_path != file_no_map[file_no]:
            #    print(f'WARNING: tiledef file number {file_no} already used by {file_no_map[file_no]}, skipping {tiledef_path}')
            continue
        update_tile_defs(defs, tiledef_path, file_no)
        file_no_map[file_no] = tiledef_path


def load_chunk(path, version=None):
    if version == 41:
        raw = Chunk_B41.parse_file(path)
    else:
        raw = Chunk.parse_file(path)
    return ChunkData(raw)


def locatete_world_dict(chunk_path):
    dir_path = os.path.dirname(chunk_path)
    world_dict_path = os.path.join(dir_path, 'WorldDictionary.bin')
    if os.path.isfile(world_dict_path):
        return os.path.normpath(world_dict_path)
    world_dict_path = os.path.join(dir_path, '..', 'WorldDictionary.bin')
    if os.path.isfile(world_dict_path):
        return os.path.normpath(world_dict_path)
    world_dict_path = os.path.join(dir_path, '..', '..', 'WorldDictionary.bin')
    if os.path.isfile(world_dict_path):
        return os.path.normpath(world_dict_path)
    return None


def load_world_dict_sprites(path, version=None):
    if not path:
        return {}
    #print(f"Loading world dictionary from {path}...")
    if version == 41:
        wd = WorldDict_B41.parse_file(path)
    else:
        wd = WorldDict.parse_file(path)
    sprite_map = {}
    for entry in wd.sprites:
        sprite_map[int(entry.id)] = decode_str_value(entry.name)
    return sprite_map


class ChunkData(object):
    """
        self.layers: A list of non-empty layers, ranges from min_layer to max_layer (exclusive)
            - self.layers[layer] is either a 2D list of size block_size x block_size, or None if that layer is empty
            - if not empty, self.layers[layer][x][y] is a list of sprite_id
    """
    def __init__(self, raw):
        self.raw = raw
        self.block_size = raw.block_size
        mask = 0
        for square in raw.squares:
            mask |= square.layer_flags
        self.init_by_mask(mask)
        for idx, square in enumerate(raw.squares):
            x, y = divmod(idx, self.block_size)
            layer = self.min_layer
            bit = self.min_layer_bit
            for grid_square in square.squares:
                while layer < self.max_layer and (square.layer_flags & bit) == 0:
                    bit <<= 1
                    layer += 1

                sprites = []
                for obj in grid_square.objects:
                    base = obj.object.base_object
                    sprite_id = getattr(base, 'sprite_id', None)
                    if isinstance(sprite_id, int):
                        sprites.append(sprite_id)

                if sprites:
                    self._set_sprites(layer, x, y, sprites)
                bit <<= 1
                layer += 1

    def init_by_mask(self, mask):
        # layer range [min_layer, max_layer)
        self.min_layer = -1
        self.min_layer_bit = 0
        self.max_layer = -1
        bit = 1
        for layer in range(64):
            if (mask & bit) != 0:
                if self.min_layer == -1:
                    self.min_layer = layer
                    self.min_layer_bit = bit
                self.max_layer = layer + 1
            bit <<= 1
        if self.min_layer == -1:
            self.min_layer = 0
            self.min_layer_bit = 0
            self.max_layer = 0
        else:
            self.min_layer -= 32
            self.max_layer -= 32
        self.layers = [None] * (self.max_layer - self.min_layer)

    def get_sprites(self, layer, x, y):
        idx = layer - self.min_layer
        if idx < 0 or idx >= len(self.layers):
            return None
        if x < 0 or x >= self.block_size:
            return None
        if y < 0 or y >= self.block_size:
            return None
        if self.layers[idx] is None:
            return None
        if self.layers[idx][x] is None:
            return None
        return self.layers[idx][x][y]

    # used by internal methods, assume layer, x, y are valid
    def _set_sprites(self, layer, x, y, sprites):
        idx = layer - self.min_layer
        if self.layers[idx] is None:
            self.layers[idx] = [None] * self.block_size
        if self.layers[idx][x] is None:
            self.layers[idx][x] = [None] * self.block_size
        self.layers[idx][x][y] = sprites

    def get_layer(self, layer):
        idx = layer - self.min_layer
        if idx < 0 or idx >= len(self.layers):
            return None
        return self.layers[idx]