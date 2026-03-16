meta:
  id: zombie_character
  endian: be
  imports:
    - character_shared

params:
  - id: world_version
    type: u4
  - id: debug
    type: u1

seq:
  - id: unknown_marker_f4
    type: f4
  - id: time_since_seen_flesh
    type: s4
  - id: fake_dead_i
    type: s4
  - id: num_worn_items
    type: u1
  - id: worn_items
    type: character_shared::worn_item_entry
    repeat: expr
    repeat-expr: num_worn_items

instances:
  fake_dead:
    value: fake_dead_i == 1