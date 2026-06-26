import os
import io
import yaml
from . import parser
from .. import mptask
import hashlib

def _process_item_file(path):
    parsed = parser.parse_file(path, type_filter=['item'])
    # parsed is dict[module_name] = { 'item': { item_name: item_data, ... }, ... }
    results = []
    for module_name, module in parsed.items():
        for item_name, item_data in module.get('item', {}).items():
            results.append(('{}.{}'.format(module_name, item_name), item_data))
    return results

def _save_cache(items, hashes, cache_path):
    with io.open(cache_path, 'w', encoding='utf-8') as f:
        yaml.dump({'items': items, 'hashes': hashes}, f, allow_unicode=True)

def _load_cache(cache_path):
    if not cache_path or not os.path.isfile(cache_path):
        return {}, {}
    with io.open(cache_path, 'r', encoding='utf-8') as f:
        data = yaml.safe_load(f)
    return data.get('items', {}), data.get('hashes', {})

def _hash_file(path, method='sha256'):
    h = hashlib.new(method)
    with open(path, 'rb') as f:
        while True:
            chunk = f.read(8192)
            if not chunk:
                break
            h.update(chunk)
    return h.hexdigest()


def _preprocess_script_file(path):
    hash = _hash_file(path)
    size = os.path.getsize(path)
    return path, hash, size

def get_items(scripts_dir, show_progress=False, parallel='auto', cache_path=None):
    # return dict[item_name] = item_data
    # item_name consists of module name and item name, e.g. "Base.Axe"
    scripts = []
    items, hashes = _load_cache(cache_path)
    if parallel == 'auto':
        num_workers = os.cpu_count()
    elif not parallel or parallel == 'off':
        num_workers = 1
    else:
        num_workers = max(1, int(parallel))

    for dirpath, _, filenames in os.walk(scripts_dir):
        for f in filenames:
            if f.endswith('.txt'):
                scripts.append(os.path.join(dirpath, f))
    coordinator = mptask.DefaultCoordinator('preprocessing scripts: {done}/{total}' if show_progress else None)
    task = mptask.Task(_preprocess_script_file, coordinator)
    script_info = task.run(scripts, num_workers)
    scripts_with_size = []
    for path, hash, size in (script_info or []):
        if path in hashes and hashes[path] == hash:
            continue
        scripts_with_size.append((path, size))
        hashes[path] = hash
    scripts = [path for path, size in sorted(scripts_with_size, key=lambda x: x[1])]

    coordinator = mptask.DefaultCoordinator('loading items scripts: {done}/{total}' if show_progress else None)
    task = mptask.Task(_process_item_file, coordinator)
    results = task.run(scripts, num_workers)

    for file_results in (results or []):
        if file_results:
            for full_name, item_data in file_results:
                items[full_name] = item_data
    if cache_path:
        _save_cache(items, hashes, cache_path)
    return items

def get_items_type_mapping(items):
    # return dict[item_name] = item_type
    mapping = {}
    for item_name, item_data in items.items():
        item_type = item_data.get('ItemType', None)
        if item_type is None:
            item_type = item_data.get('Type', None)
        if item_type:
            mapping[item_name] = item_type
    return mapping

DEFAULT_SCRIPTS_DIR = r"D:\SteamLibrary\steamapps\common\ProjectZomboid\media\scripts"
if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser(description="Extract items from Project Zomboid scripts")
    parser.add_argument('-s', '--scripts-dir', default=DEFAULT_SCRIPTS_DIR, help="Directory to search for scripts")
    parser.add_argument('-p', '--parallel', type=int, default=os.cpu_count(), help="Number of parallel workers (default: cpu count)")
    parser.add_argument('--cache', default=None, help="Path to cache file (default: no cache)")
    args = parser.parse_args()

    items = get_items(args.scripts_dir, show_progress=True, parallel=args.parallel, cache_path=args.cache)
    type_mapping = get_items_type_mapping(items)
    print(f"Found {len(items)} items")