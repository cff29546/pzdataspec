import argparse
import os
import yaml

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DEFAULT_MAPPING_PATH = os.path.join(BASE_DIR, "../data_spec/spec/version_mapping.yaml")
DEFAULT_RELEASE_NOTES_PATH = os.path.join(BASE_DIR, "../output/release/release_notes.md")
DEFAULT_SPEC_DIR = os.path.join(BASE_DIR, "../data_spec/spec")

def load_version_mapping(path):
    mapping = {}
    with open(path, "r", encoding="utf-8") as f:
        data = yaml.safe_load(f.read())
    for key, value in data.items():
        if isinstance(key, int) and isinstance(value, str):
            mapping[key] = value.strip()
    return mapping


def gen_notes_text(mapping, versions, latest_world=None):
    lines = []
    lines.append("# pzdataspec release artifacts")
    lines.append("")
    lines.append("| Asset | World version | Game version |")
    lines.append("|---|---:|---|")

    for v in versions:
        game_version = mapping.get(v, "Unknown")
        asset_name = f"pzdataspec-{v}.zip"
        if v == latest_world:
            asset_name += " (latest)"
        lines.append(f"| {asset_name} | {v} | {game_version} |")

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