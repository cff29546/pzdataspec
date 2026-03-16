import struct


def gen_binary(with_optional=False):
    data = struct.pack("B", 42)
    if with_optional:
        data += struct.pack("B", 99)
    return data


def parse_binary(data):
    head = struct.unpack_from("B", data, 0)[0]
    optional = struct.unpack_from("B", data, 1)[0] if len(data) > 1 else None
    return {"head": head, "optional": optional}


if __name__ == "__main__":
    import argparse
    import os

    parser = argparse.ArgumentParser(description="Generate binary for remaining stream conditional typing example.")
    parser.add_argument("--optional", action="store_true")
    parser.add_argument("--output", type=str, default="../output/remaining_stream_conditional_typing.bin")
    args = parser.parse_args()

    out_path = os.path.abspath(args.output)
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    with open(out_path, "wb") as f:
        blob = gen_binary(args.optional)
        f.write(blob)

    parsed = parse_binary(blob)
    if parsed["head"] != 42:
        raise RuntimeError("Round-trip head mismatch")
    if args.optional and parsed["optional"] != 99:
        raise RuntimeError("Round-trip optional mismatch")
    if (not args.optional) and parsed["optional"] is not None:
        raise RuntimeError("Round-trip unexpected optional value")

    print("Round-trip OK")
    print(f"Wrote: {out_path}")
