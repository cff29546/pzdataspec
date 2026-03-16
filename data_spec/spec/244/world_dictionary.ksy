meta:
  id: world_dictionary
  endian: be
  imports:
    - ../common/common
    - inventory
    - erosion
doc: |
  Binary layout for the world dictionary as written with ByteBuffer in-game.
    Structure derived from world.DictionaryData.saveToByteBuffer / loadFromByteBuffer and related classes.
seq:
  - id: version
    type: s4
  - id: next_info_id
    type: s2
  - id: mext_object_name_id
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
  - id: num_entities
    type: s4
  - id: entities
    type: dict_info(num_mod_ids, num_modules)
    repeat: expr
    repeat-expr: num_entities
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
  - id: string_dictionary
    type: string_dictionary
  - id: scripts_dictionary
    type: scripts_dictionary

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

  # world.StringDictionary.saveToByteBuffer / loadFromByteBuffer
  string_dictionary:
    seq:
      - id: num_registers
        type: s4
      - id: registers
        type: register
        repeat: expr
        repeat-expr: num_registers

  # world.StringDictionary.StringRegister.save / load
  register:
    seq:
      - id: name
        type: common::string_utf
      - id: block_size
        type: s4
      - id: next_id
        type: s2
      - id: num_strings
        type: s4
      - id: strings
        type: string_info
        repeat: expr
        repeat-expr: num_strings

  # world.DictionaryStringInfo.save / load
  string_info:
    seq:
      - id: flags
        type: u1
      - id: registry_id
        type: s2
      - id: is_base
        type: u1
      - id: raw_string
        type: common::string_utf
    instances:
      string:
        value: '(flags & 1) != 0 ? "Base." + raw_string.value : raw_string.value'

  # world.ScriptsDictionary.saveToByteBuffer / loadFromByteBuffer
  scripts_dictionary:
    seq:
      - id: num_scripts
        type: s4
      - id: scripts
        type: script_info
        repeat: expr
        repeat-expr: num_scripts

  # world.ScriptsDictionary.ScriptRegister.save / load
  script_info:
    seq:
      - id: name
        type: common::string_utf
      - id: block_size
        type: s4
      - id: next_id
        type: s2
      - id: num_scripts
        type: s4
      - id: scripts
        type: script_data
        repeat: expr
        repeat-expr: num_scripts
    
  # world.DictionaryScriptInfo.save / load
  script_data:
    seq:
      - id: flags
        type: u1
      - id: registry_id
        type: s2
      - id: version
        type: s8
      - id: raw_script
        type: common::string_utf
    instances:
      script:
        value: '(flags & 1) != 0 ? "Base." + raw_script.value : raw_script.value'