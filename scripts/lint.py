import os
import sys
import argparse

def lint_file(file_path):
    content = ''
    with open(file_path, "r", encoding="utf-8") as file:
        content = file.read()
    content_lint = content.strip() + "\n"  # Ensure the file ends with a newline
    if content != content_lint:
        print(f"Linting {file_path}...")
        with open(file_path, "w", encoding="utf-8") as file:
            file.write(content_lint)

def process(path):
    if os.path.isfile(path) and path.endswith(".ksy"):
        lint_file(path)
    elif os.path.isdir(path):
        for root, _, files in os.walk(path):
            for file in files:
                if file.endswith(".ksy"):
                    lint_file(os.path.join(root, file))

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Run linting on the codebase.")
    parser.add_argument("targets", nargs=argparse.REMAINDER, help="Specific files or directories to lint. Defaults to the current directory.")
    args = parser.parse_args()

    targets = args.targets if args.targets else []
    for target in targets:
        process(target)
