meta:
  id: world_dictionary
  endian: be
  imports:
    - ../common/common
doc: |
  Binary layout for build-195 world dictionary.
    Structure derived from zombie.world.DictionaryData.saveToByteBuffer / loadFromByteBuffer.
seq:
  - id: next_info_id
    type: s2
  - id: next_object_name_id
    type: s1
  - id: next_sprite_name_id
    type: s4
  - id: num_mod_ids
    type: s4
  - id: mod_ids
    type: common::string_utf
    repeat: expr
    repeat-expr: num_mod_ids
  - id: num_modules
    type: s4
  - id: modules
    type: common::string_utf
    repeat: expr
    repeat-expr: num_modules
  - id: num_items
    type: s4
  - id: items
    type: dict_info(num_mod_ids, num_modules)
    repeat: expr
    repeat-expr: num_items
  - id: num_objects
    type: s4
  - id: objects
    type: object_entry
    repeat: expr
    repeat-expr: num_objects
  - id: num_sprites
    type: s4
  - id: sprites
    type: sprite_entry
    repeat: expr
    repeat-expr: num_sprites

types:
  # world.DictionaryData.save / load
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
                true: s2
                false: s1
      - id: name
        type: common::string_utf
      - id: flags
        type: u1
      - id: mod_id
        if: (flags & 1) != 0
        type:
            switch-on: num_mod_ids > 127
            cases:
                true: s2
                false: s1
      - id: raw_num_mod_overrides
        type: u1
        if: (flags & 16) != 0 and (flags & 32) == 0
      - id: mod_overrides
        type:
            switch-on: num_mod_ids > 127
            cases:
                true: s2
                false: s1
        repeat: expr
        repeat-expr: num_mod_overrides
        if: (flags & 16) != 0
    instances:
      num_mod_overrides:
        value: '(flags & 32) != 0 ? 1 : (flags & 16) != 0 ? raw_num_mod_overrides : 0'

  object_entry:
    seq:
      - id: id
        type: u1
      - id: name
        type: common::string_utf

  sprite_entry:
    seq:
      - id: id
        type: s4
      - id: name
        type: common::string_utf