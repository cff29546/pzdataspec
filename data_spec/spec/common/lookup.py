class LookupStrz:
    def __init__(self, mapping, key, default=''):
        if mapping and key in mapping:
            self.value = mapping[key].encode('utf-8') + b'\x00'
        else:
            self.value = default.encode('utf-8') + b'\x00'

    def decode(self, data):
        return self.value