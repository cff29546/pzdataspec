meta:
  id: dictionary_data
  endian: be
doc: |
  Example for variable-length arrays + conditional fields + bitmap flags.
  Derived from DictionaryData.save(ByteBuffer).

seq:
  - id: num_mod_ids
    type: s4
    valid:
      min: 0
  - id: num_modules
    type: s4
    valid:
      min: 0
  - id: num_entries
    type: s4
    valid:
      min: 0
  - id: entries
    type: dict_info(num_mod_ids, num_modules)
    repeat: expr
    repeat-expr: num_entries

types:
  dict_info:
    params:
      - id: num_mod_ids
        type: s4
      - id: num_modules
        type: s4
    seq:
      - id: registry_id
        type: s2
      - id: module_index
        type:
          switch-on: num_modules > 127
          cases:
            true: u2
            false: u1
      - id: name
        type: string_utf
      - id: flags
        type: u1
        valid:
          expr: ((_ & 0x31) ^ _) == 0
        doc: |
          Bit flags:
            0x01 => mod_id exists
            0x10 => mod_overrides enabled
            0x20 => single override implicit (count = 1)
      - id: mod_id
        if: (flags & 1) != 0
        type:
          switch-on: num_mod_ids > 127
          cases:
            true: u2
            false: u1
      - id: raw_num_mod_overrides
        if: (flags & 0x10) != 0 and (flags & 0x20) == 0
        type: u1
      - id: mod_overrides
        if: (flags & 0x10) != 0
        type:
          switch-on: num_mod_ids > 127
          cases:
            true: u2
            false: u1
        repeat: expr
        repeat-expr: num_mod_overrides
    instances:
      num_mod_overrides:
        value: '(flags & 0x10) != 0 ? ((flags & 0x20) != 0 ? 1 : raw_num_mod_overrides) : 0'

  string_utf:
    seq:
      - id: len_value
        type: u2
      - id: value
        type: str
        size: len_value
        encoding: UTF-8
