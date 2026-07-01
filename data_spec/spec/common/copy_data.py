import struct

class U4le:
    def __init__(self, value):
        self.value = struct.pack('<I', value)

    def decode(self, data):
        return self.value