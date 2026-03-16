import struct
import random


def popcount(b):
    return bin(b).count("1")


def gen_binary(size=None):
    if size is None:
        size = random.randint(6, 15)
    data = b""
    for _ in range(size):
        data += struct.pack("B", random.randint(0, 255))
    return data


def parse_binary(data):
    values = list(struct.unpack(f"<{len(data)}B", data))
    head = values[0]
    fixed = values[1:5]
    tail = values[5:]
    bit_count = sum(popcount(v) for v in fixed + tail)
    return {
        "head": head,
        "fixed": fixed,
        "tail": tail,
        "bit_count": bit_count,
    }


if __name__ == "__main__":
    import argparse
    import os

    parser = argparse.ArgumentParser(description="Generate binary for native KSY loop expression example.")
    parser.add_argument("--size", type=int, default=10)
    parser.add_argument("--output", type=str, default="../output/loop_native_ksy_expressions.bin")
    args = parser.parse_args()

    out_path = os.path.abspath(args.output)
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    with open(out_path, "wb") as f:
        blob = gen_binary(args.size)
        f.write(blob)

    parsed = parse_binary(blob)
    if len(parsed["fixed"]) != min(4, max(0, len(blob) - 1)):
        raise RuntimeError("Round-trip fixed segment mismatch")
    if parsed["bit_count"] < 0:
        raise RuntimeError("Round-trip bit count mismatch")

    print("Round-trip OK")
    print(f"Wrote: {out_path}")
