class LookupStrz:
    def __init__(self, context, mapping_name, key, default=''):
        if not isinstance(context, dict):
            self.value = default.encode('utf-8') + b'\x00'
            return
        mapping = context.get(mapping_name, None)
        if mapping and key in mapping:
            self.value = mapping[key].encode('utf-8') + b'\x00'
        else:
            self.value = default.encode('utf-8') + b'\x00'

    def decode(self, data):
        return self.value
