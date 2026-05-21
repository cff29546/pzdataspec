import struct


class U4ToStrzMapping:
    def __init__(self, mapping, default=''):
        self.mapping = mapping
        self.default = default.encode('utf-8') + b'\x00'

    def decode(self, data):
        if not self.mapping:
            return self.default
        key = struct.unpack('<I', data)[0]
        if key not in self.mapping:
            return self.default
        value = self.mapping[key]
        return value.encode('utf-8') + b'\x00'
