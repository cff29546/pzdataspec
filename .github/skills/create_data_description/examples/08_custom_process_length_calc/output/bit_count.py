import struct


class BitCount:
    def decode(self, data):
        value = struct.unpack("<Q", data)[0]
        count = bin(value).count("1")
        return struct.pack("<Q", count)
