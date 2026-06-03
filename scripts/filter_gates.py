import argparse
import subprocess
import sys


def main():
    parser = argparse.ArgumentParser(description="Filter version gates in source code using rg")
    parser.add_argument("source_root", help="Root directory to search")
    parser.add_argument("min_version", type=int, help="Minimum version (inclusive)")
    parser.add_argument("max_version", type=int, help="Maximum version (inclusive)")
    parser.add_argument("-o", "--output", help="Output file (default: stdout)")
    args = parser.parse_args()

    out = open(args.output, "w", encoding="utf-8") if args.output else sys.stdout
    try:
        for ver in range(args.min_version, args.max_version + 1):
            pattern = f">= {ver}"
            result = subprocess.run(
                ["rg", pattern, args.source_root],
                capture_output=True, text=True
            )
            if result.stdout:
                out.write(result.stdout)
    finally:
        if out is not sys.stdout:
            out.close()


if __name__ == "__main__":
    main()
