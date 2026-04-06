import argparse
import os
import re
import shutil
import struct
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable


CHUNK_PATTERNS = (
    re.compile(r"^map_(?P<x>-?\d+)_(?P<y>-?\d+)\.bin$", re.IGNORECASE),
    re.compile(r"^map[/\\]map_(?P<x>-?\d+)_(?P<y>-?\d+)\.bin$", re.IGNORECASE),
    re.compile(r"^map[/\\](?P<x>-?\d+)[/\\](?P<y>-?\d+)\.bin$", re.IGNORECASE),
)


@dataclass(frozen=True)
class ChunkFile:
    rel_path: Path
    x: int
    y: int


def parse_focus_point(point: str) -> tuple[int, int]:
    match = re.fullmatch(r"\s*(-?\d+)x(-?\d+)\s*", point)
    if not match:
        raise ValueError(f"Invalid focus point '{point}'. Expected format like 1234x5678.")
    return int(match.group(1)), int(match.group(2))


def parse_chunk_path(rel_path: Path) -> ChunkFile | None:
    rel_str = rel_path.as_posix()
    for pattern in CHUNK_PATTERNS:
        match = pattern.fullmatch(rel_str)
        if match:
            return ChunkFile(rel_path=rel_path, x=int(match.group("x")), y=int(match.group("y")))
    return None


def iter_all_files(root: Path) -> Iterable[Path]:
    for path in root.rglob("*"):
        if path.is_file():
            yield path


def discover_chunk_files(src_root: Path) -> list[ChunkFile]:
    chunks: list[ChunkFile] = []
    for file_path in iter_all_files(src_root):
        rel_path = file_path.relative_to(src_root)
        parsed = parse_chunk_path(rel_path)
        if parsed is not None:
            chunks.append(parsed)
    return chunks


def read_world_version_from_chunk(src_root: Path, chunk: ChunkFile) -> int:
    chunk_path = src_root / chunk.rel_path
    with chunk_path.open("rb") as f:
        header = f.read(8)
    if len(header) < 5:
        raise ValueError(f"Chunk file too small to read world version: {chunk_path}")

    candidates = [
        struct.unpack(">I", header[1:5])[0],  # Expected layout: [debug:u1][world_version:u4(be)]
        struct.unpack(">I", header[0:4])[0],  # Fallback if no debug byte is present
    ]
    if len(header) >= 6:
        candidates.append(struct.unpack("<I", header[1:5])[0])
        candidates.append(struct.unpack("<I", header[0:4])[0])

    for world_version in candidates:
        if 1 <= world_version <= 100000:
            return int(world_version)

    raise ValueError(f"Unexpected world version candidates {candidates} from chunk: {chunk_path}")


def resolve_world_version(src_root: Path, chunk_files: list[ChunkFile], explicit_version: int | None) -> int:
    if explicit_version is not None:
        return explicit_version
    if not chunk_files:
        raise ValueError("No chunk files found in source save; use --world-version to continue.")
    return read_world_version_from_chunk(src_root, chunk_files[0])


def target_chunk_coords(focus_points: list[tuple[int, int]], block_size: int, radius: int) -> set[tuple[int, int]]:
    keep: set[tuple[int, int]] = set()
    for sx, sy in focus_points:
        cx = sx // block_size
        cy = sy // block_size
        for dx in range(-radius, radius + 1):
            for dy in range(-radius, radius + 1):
                keep.add((cx + dx, cy + dy))
    return keep


def copy_save_with_focus(
    src_root: Path,
    dst_root: Path,
    keep_chunks: set[tuple[int, int]],
) -> tuple[int, int, int]:
    copied_total = 0
    copied_chunks = 0
    skipped_chunks = 0

    for src_file in iter_all_files(src_root):
        rel_path = src_file.relative_to(src_root)
        chunk = parse_chunk_path(rel_path)
        if chunk is not None:
            if (chunk.x, chunk.y) not in keep_chunks:
                skipped_chunks += 1
                continue
            copied_chunks += 1

        dst_file = dst_root / rel_path
        dst_file.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src_file, dst_file)
        copied_total += 1

    return copied_total, copied_chunks, skipped_chunks


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(
        description=(
            "Duplicate a Project Zomboid save while keeping only chunk files near focused square coordinates."
        )
    )
    parser.add_argument("src_save_game", help="Source save folder path")
    parser.add_argument(
        "focus_points",
        nargs="+",
        help="Focused square coordinates in format like 1234x5678",
    )
    parser.add_argument("-o", "--output", required=True, help="Destination folder path")
    parser.add_argument(
        "-r",
        "--radius",
        type=int,
        default=2,
        help="Chunk radius around each focus chunk (default: 2 -> 5x5 area)",
    )
    parser.add_argument(
        "--world-version",
        type=int,
        default=None,
        help="Override world version detection; useful when no chunk files are present",
    )
    args = parser.parse_args(argv)

    src_root = Path(args.src_save_game).resolve()
    dst_root = Path(args.output).resolve()

    if not src_root.is_dir():
        print(f"Source save folder not found: {src_root}", file=sys.stderr)
        return 1
    if args.radius < 0:
        print("Radius must be >= 0", file=sys.stderr)
        return 1
    if dst_root == src_root:
        print("Destination must be different from source folder.", file=sys.stderr)
        return 1
    if src_root in dst_root.parents:
        print("Destination cannot be inside source folder.", file=sys.stderr)
        return 1

    focus_points: list[tuple[int, int]] = []
    try:
        for item in args.focus_points:
            focus_points.append(parse_focus_point(item))
    except ValueError as e:
        print(str(e), file=sys.stderr)
        return 1

    chunk_files = discover_chunk_files(src_root)
    try:
        world_version = resolve_world_version(src_root, chunk_files, args.world_version)
    except ValueError as e:
        print(str(e), file=sys.stderr)
        return 1

    block_size = 10 if world_version <= 195 else 8
    keep_chunks = target_chunk_coords(focus_points, block_size, args.radius)

    if dst_root.exists() and any(dst_root.iterdir()):
        print(f"Destination must not be a non-empty folder: {dst_root}", file=sys.stderr)
        return 1
    dst_root.mkdir(parents=True, exist_ok=True)

    copied_total, copied_chunks, skipped_chunks = copy_save_with_focus(src_root, dst_root, keep_chunks)

    print(f"World version: {world_version}")
    print(f"Block size: {block_size}")
    print(f"Focus points: {len(focus_points)}")
    print(f"Keep chunk coords: {len(keep_chunks)}")
    print(f"Detected chunk files: {len(chunk_files)}")
    print(f"Copied chunk files: {copied_chunks}")
    print(f"Skipped chunk files: {skipped_chunks}")
    print(f"Copied total files: {copied_total}")
    print(f"Destination: {dst_root}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))