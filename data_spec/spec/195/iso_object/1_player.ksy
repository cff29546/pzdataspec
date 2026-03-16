meta:
  id: player
  endian: be
  imports:
    - ../../common/common
    - character_shared

params:
  - id: world_version
    type: u4
  - id: debug
    type: u1

seq:
  - id: unknown_header_1
    type: u1
  - id: unknown_header_2
    type: u1
  - id: hours_survived
    type: f8
  - id: zombie_kills
    type: s4
  - id: num_worn_items
    type: u1
  - id: worn_items
    type: character_shared::worn_item_entry
    repeat: expr
    repeat-expr: num_worn_items
  - id: left_hand_index
    type: s2
  - id: right_hand_index
    type: s2
  - id: survivor_kills
    type: s4
  - id: nutrition
    type: character_shared::nutrition_data
  - id: all_chat_muted
    type: u1
  - id: tag_prefix
    type: common::string_utf
  - id: tag_color_r
    type: f4
  - id: tag_color_g
    type: f4
  - id: tag_color_b
    type: f4
  - id: display_name
    type: common::string_utf
  - id: show_tag
    type: u1
  - id: faction_pvp
    type: u1
  - id: no_clip
    type: u1
    if: world_version >= 176
  - id: has_saved_vehicle
    type: u1
  - id: saved_vehicle_x
    type: f4
    if: has_saved_vehicle == 1
  - id: saved_vehicle_y
    type: f4
    if: has_saved_vehicle == 1
  - id: saved_vehicle_seat
    type: s1
    if: has_saved_vehicle == 1
  - id: saved_vehicle_running
    type: u1
    if: has_saved_vehicle == 1
  - id: num_mechanics_items
    type: s4
  - id: mechanics_items
    type: character_shared::mechanics_item_entry
    repeat: expr
    repeat-expr: num_mechanics_items
  - id: fitness
    type: character_shared::fitness_data(world_version)
  - id: num_already_read_books
    type: s2
    if: world_version >= 184
  - id: already_read_books
    type: character_shared::already_read_book_entry
    repeat: expr
    repeat-expr: num_already_read_books
    if: world_version >= 184
  - id: num_legacy_already_read_books
    type: s4
    if: world_version >= 182 and world_version < 184
  - id: legacy_already_read_books
    type: common::string_utf
    repeat: expr
    repeat-expr: num_legacy_already_read_books
    if: world_version >= 182 and world_version < 184
  - id: known_media_lines
    type: character_shared::known_media_lines_data
    if: world_version >= 189