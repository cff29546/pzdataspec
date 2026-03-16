import struct
import random


def popcount(x):
    return bin(x).count("1")


def gen_row():
    flags = random.getrandbits(64)
    data = struct.pack("<Q", flags)
    for _ in range(popcount(flags)):
        data += struct.pack("<I", 0)
    return data


def parse_row(data, offset):
    flags = struct.unpack_from("<Q", data, offset)[0]
    offset += 8
    n = popcount(flags)
    values = []
    for _ in range(n):
        values.append(struct.unpack_from("<I", data, offset)[0])
        offset += 4
    return {"flags": flags, "values": values}, offset


def gen_binary(rows=8):
    data = b""
    for _ in range(rows):
        data += gen_row()
    return data


def parse_binary(data, rows=8):
    offset = 0
    parsed = []
    for _ in range(rows):
        row, offset = parse_row(data, offset)
        parsed.append(row)
    if offset != len(data):
        raise ValueError(f"Trailing bytes detected: {len(data) - offset}")
    return parsed


if __name__ == "__main__":
    import argparse
    import os

    parser = argparse.ArgumentParser(description="Generate binary for custom process example.")
    parser.add_argument("--rows", type=int, default=8)
    parser.add_argument("--output", type=str, default="../output/custom_process_length_calc.bin")
    args = parser.parse_args()

    out_path = os.path.abspath(args.output)
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    with open(out_path, "wb") as f:
        blob = gen_binary(args.rows)
        f.write(blob)

    parsed = parse_binary(blob, args.rows)
    if len(parsed) != args.rows:
        raise RuntimeError("Round-trip parse row count mismatch")

    print("Round-trip OK")
    print(f"Wrote: {out_path}")
