import argparse
import os
import yaml

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DEFAULT_MAPPING_PATH = os.path.join(BASE_DIR, "../data_spec/spec/version_mapping.yaml")
DEFAULT_RELEASE_NOTES_PATH = os.path.join(BASE_DIR, "../output/release/release_notes.md")
DEFAULT_SPEC_DIR = os.path.join(BASE_DIR, "../data_spec/spec")


def latest(version1, version2):
    # Compare two version strings and return the latest one
    def gt(v1, v2):
        if v1 == v2:
            return False
        if v1.isdigit() and v2.isdigit():
            return int(v1) > int(v2)
        return v1 > v2

    v1_parts = version1.split(".")
    v2_parts = version2.split(".")
    
    for p1, p2 in zip(v1_parts, v2_parts):
        if gt(p1, p2):
            return version1
        elif gt(p2, p1):
            return version2
    
    # If all parts are equal so far, the longer version is considered later
    if len(v1_parts) > len(v2_parts):
        return version1
    else:
        return version2


def load_version_mapping(path):
    mapping = {}
    with open(path, "r", encoding="utf-8") as f:
        data = yaml.safe_load(f.read())
    for key, value in data.items():
        if not isinstance(key, str) or not isinstance(value, int):
            continue
        if value in mapping:
            key = latest(key, mapping[value])
        mapping[value] = key
    return mapping


def gen_notes_text(mapping, versions, latest_world=None):
    lines = []
    lines.append("# pzdataspec release artifacts")
    lines.append("")
    lines.append("| Data spec version (world version) | Latest Supported Game version |")
    lines.append("|---|---|")

    for v in versions:
        game_version = mapping.get(v, "Unknown")
        lines.append(f"| {v} | {game_version} |")

    lines.append("")
    return "\n".join(lines)


def build_notes(args):
    versions = []
    for name in os.listdir(args.spec_dir):
        if not os.path.isdir(os.path.join(args.spec_dir, name)):
            continue
        if not name.isdigit():
            continue
        versions.append(int(name))
    if not versions:
        return "No world versions found in spec directory."
    versions.sort()

    mapping = load_version_mapping(args.mapping)
    latest_world = versions[-1]
    if args.target == "latest":
        versions = [latest_world]
    elif args.target != "all":
        if (args.target.isdigit()
            and os.path.isdir(os.path.join(args.spec_dir, args.target))
            and int(args.target) in mapping):
            versions = [int(args.target)]
        else:
            return "Invalid target specified. Use 'all', 'latest', or a valid world version number."
    
    return gen_notes_text(mapping, versions, latest_world)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("target", help="Target world version, can be 'all' or 'latest'", default="all")
    parser.add_argument("-m", "--mapping", help="Path to version_mapping.yaml", default=DEFAULT_MAPPING_PATH)
    parser.add_argument("-o", "--output", help="Output markdown file path", default=DEFAULT_RELEASE_NOTES_PATH)
    parser.add_argument("-s", "--spec-dir", help="Path to data_spec directory", default=DEFAULT_SPEC_DIR)
    args = parser.parse_args()
 
    notes = build_notes(args)
    if args.output:
        basedir = os.path.dirname(args.output)
        os.makedirs(basedir, exist_ok=True)
        with open(args.output, "w", encoding="utf-8") as f:
            f.write(notes)
    else:
        print(notes)


if __name__ == "__main__":
    main()