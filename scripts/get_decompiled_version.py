import argparse
import os
import re
import sys
import yaml

def core_version(core_java):
    """
    This method extracts the game version from the Core.java source code.

    First locate the getVersion function, using the keyword ' new GameVersion(' to find:
        private static final GameVersion gameVersion = new GameVersion(<major>, <minor>, "<suffix>");
    
    Then return the version as a string in the format "<major>.<minor><suffix>.<build>"
    """
    if not os.path.isfile(core_java):
        return None
    with open(core_java, "r", encoding="utf-8") as f:
        source = f.read()
    version_match = re.search(r'new GameVersion\((\d+), (\d+), "([^"]*)"', source)
    if not version_match:
        return None
    major = version_match.group(1)
    minor = version_match.group(2)
    suffix = version_match.group(3)
    build_match = re.search(r'int buildVersion = (\d+);', source)
    build = build_match.group(1) if build_match else 0
    return f"{major}.{minor}{suffix}.{build}"
def iso_chunk_version(iso_chunk_java):
    """
    This method extracts the world version from the IsoChunk.java source code.

    First locate the Save function, using the keyword ' Save(ByteBuffer' to find:
        public ByteBuffer Save(ByteBuffer bb, ...

    Then locate the line that assigns the world version, using the first match of the pattern '.putInt(<version>);'
    """
    if not os.path.isfile(iso_chunk_java):
        return None
    with open(iso_chunk_java, "r", encoding="utf-8") as f:
        source = f.read()
    save_function_match = re.search(r' Save\(ByteBuffer', source)
    if not save_function_match:
        return None
    save_function_start = save_function_match.start()
    put_int_matches = re.search(r'\.putInt\((\d+)\);', source[save_function_start:])
    if not put_int_matches:
        return None
    world_version = int(put_int_matches.group(1))
    return world_version

def meta_tracker_version(meta_tracker_java):
    """
    This method extracts the world version from the MetaTracker.java source code.

    First locate the save function, using the keyword ' save(' to find:
       public static void save() {
    
    Then locate the line that assigns the world version, using the first match of the pattern '.putInt(<version>);'
    """
    if not os.path.isfile(meta_tracker_java):
        return None
    with open(meta_tracker_java, "r", encoding="utf-8") as f:
        source = f.read()
    save_function_match = re.search(r' save\(', source)
    if not save_function_match:
        return None
    save_function_start = save_function_match.start()
    put_int_matches = re.search(r'\.putInt\((\d+)\);', source[save_function_start:])
    if not put_int_matches:
        return None
    world_version = int(put_int_matches.group(1))
    return world_version

def get_world_version(source_path):
    iso_chunk_java = os.path.join(source_path, "zombie", "iso", "IsoChunk.java")
    meta_tracker_java = os.path.join(source_path, "zombie", "iso", "MetaTracker.java")
    iso_chunk_ver = iso_chunk_version(iso_chunk_java)
    meta_tracker_ver = meta_tracker_version(meta_tracker_java)
    if iso_chunk_ver != meta_tracker_ver:
        sys.stderr.write(f"Warning: IsoChunk version ({iso_chunk_ver}) and MetaTracker version ({meta_tracker_ver}) do not match.")
    if iso_chunk_ver is None:
        sys.stderr.write("Error: Could not determine world version.\n")
    
    version = iso_chunk_ver if iso_chunk_ver is not None else meta_tracker_ver
    version = version if version is not None else 'unknown_world_version'
    return version

def get_game_version(source_path):
    core_java = os.path.join(source_path, "zombie", "core", "Core.java")
    version = core_version(core_java)
    if version is None:
        sys.stderr.write("Error: Could not determine game version.\n")
    return version

def print_version(version_function, cmd_args):
    parser = argparse.ArgumentParser(description="Get the world version of decompiled Project Zomboid Java source.")
    parser.add_argument("source_path", type=str, help="The path to the decompiled Java source directory.")
    args = parser.parse_args(cmd_args)
    version = version_function(args.source_path)
    print(version)

def update_version_mapping(cmd_args):
    parser = argparse.ArgumentParser(description="Update the version mapping for decompiled Project Zomboid Java source.")
    parser.add_argument("decompiled_root", type=str, help="The root directory of the decompiled Java source.")
    parser.add_argument("mapping_file", type=str, help="The YAML file to update the version mapping in.", nargs='?', default=None)
    args = parser.parse_args(cmd_args)

    mapping = {}
    if args.mapping_file and os.path.isfile(args.mapping_file):
        with open(args.mapping_file, "r", encoding="utf-8") as f:
            mapping = yaml.safe_load(f) or {}
    
    for folder in os.listdir(args.decompiled_root):
        folder_path = os.path.join(args.decompiled_root, folder)
        if os.path.isdir(folder_path):
            world_version = get_world_version(folder_path)
            game_version = get_game_version(folder_path)
            if world_version and game_version:
                full_version = f"{game_version}_{world_version}"
                mapping[game_version] = world_version
                if folder != full_version:
                    if os.path.exists(os.path.join(args.decompiled_root, full_version)):
                        print(f"Warning: Target folder '{full_version}' already exists. Skipping renaming of '{folder}'.")
                    else:
                        os.rename(folder_path, os.path.join(args.decompiled_root, full_version))
                        print(f"Renamed '{folder}' to '{full_version}'")

    if args.mapping_file:
        with open(args.mapping_file, "w", encoding="utf-8") as f:
            yaml.dump(mapping, f)
    else:
        print(yaml.dump(mapping))

CMD = {
    "world": lambda args: print_version(get_world_version, args),
    "game": lambda args: print_version(get_game_version, args),
    "update": update_version_mapping,
}

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Get the world version of decompiled Project Zomboid Java source.")
    parser.add_argument("cmd", type=str, choices=CMD.keys(), help="The command to execute. 'world' to get the world version, 'game' to get the game version, 'update' to update the version mapping.")
    parser.add_argument("args", nargs="*", help="Arguments for the command.")
    args = parser.parse_args()

    if args.cmd not in CMD:
        sys.stderr.write(f"Error: Invalid command '{args.cmd}'. Valid commands are: {', '.join(CMD.keys())}.\n")
        sys.exit(1)
    
    CMD[args.cmd](args.args)