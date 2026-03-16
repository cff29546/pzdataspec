meta:
  id: dead_body
  endian: be
  imports:
    - ../../common/common
    - ../inventory
    - ../visual
    - character_shared
params:
  - id: world_version
    type: u4
  - id: debug
    type: u1
seq:
  - id: female
    type: u1
  - id: was_zombie
    type: u1
  - id: object_id
    type: s2
    if: world_version >= 192
  - id: is_online_server
    type: u1
  - id: persistent_outfit_id
    type: s4
    if: world_version >= 171
  - id: legacy_online_id
    type: s2
    if: world_version < 171 and is_online_server == 1
  - id: has_desc
    type: u1
  - id: desc
    type: character_shared::survivor_desc(world_version)
    if: has_desc == 1
  - id: visual_type
    type: u1
    if: world_version >= 190
    valid:
      expr: _ == 0
  - id: visual
    if: world_version >= 190
    type:
      switch-on: visual_type
      cases:
        0: visual::human_visual
  - id: visual_legacy
    type: visual::human_visual
    if: world_version < 190
  - id: has_container
    type: u1
  - id: container_data
    type: container_with_worn_items(world_version)
    if: has_container == 1
  - id: death_time
    type: f4
  - id: reanimate_time
    type: f4
  - id: fall_on_front
    type: u1
  - id: was_skeleton
    type: u1
  - id: angle
    type: f4
    if: world_version >= 159
  - id: zombie_rot_stage_at_death
    type: u1
    if: world_version >= 166
  - id: crawling
    type: u1
    if: world_version >= 168
  - id: fake_dead
    type: u1
    if: world_version >= 168
types:
  container_with_worn_items:
    params:
      - id: world_version
        type: u4
    seq:
      - id: container_id
        type: s4
      - id: container
        type: inventory::container(world_version)
      - id: num_worn_items
        type: u1
      - id: worn_items
        type: character_shared::worn_item_entry
        repeat: expr
        repeat-expr: num_worn_items
      - id: num_attached_items
        type: u1
      - id: attached_items
        type: attached_item_entry
        repeat: expr
        repeat-expr: num_attached_items
  attached_item_entry:
    seq:
      - id: location
        type: common::string_utf
      - id: item_index
        type: s2
  bone_transform_array:
    seq:
      - id: num_bones
        type: s4
      - id: bones
        type: bone_transform
        repeat: expr
        repeat-expr: num_bones
  bone_transform:
    seq:
      - id: bone_id
        type: s4
      - id: position_x
        type: f4
      - id: position_y
        type: f4
      - id: position_z
        type: f4
      - id: quaternion_x
        type: f4
      - id: quaternion_y
        type: f4
      - id: quaternion_z
        type: f4
      - id: quaternion_w
        type: f4
      - id: scale_x
        type: f4
      - id: scale_y
        type: f4
      - id: scale_z
        type: f4
