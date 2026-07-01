meta:
  id: item_hand_weapon
  endian: be
  imports:
    - ../../common/common

params:
  - id: context
    type: any
  - id: world_version
    type: u4

# zombie.inventory.types.HandWeapon.save / load
# Extends: InventoryItem
seq:
  - id: flags
    type: u4
  - id: max_range
    type: f4
    if: (flags & 1) != 0
  - id: min_range_ranged
    type: f4
    if: (flags & 2) != 0
  - id: clip_size
    type: s4
    if: (flags & 4) != 0
  - id: min_damage
    type: f4
    if: (flags & 8) != 0
  - id: max_damage
    type: f4
    if: (flags & 16) != 0
  - id: recoil_delay
    type: s4
    if: (flags & 32) != 0
  - id: aiming_time
    type: s4
    if: (flags & 64) != 0
  - id: reload_time
    type: s4
    if: (flags & 128) != 0
  - id: hit_chance
    type: s4
    if: (flags & 256) != 0
  - id: min_angle
    type: f4
    if: (flags & 512) != 0
  - id: scope_registry_id
    type: u2
    if: (flags & 1024) != 0
  - id: clip_registry_id
    type: u2
    if: (flags & 2048) != 0
  - id: recoilpad_registry_id
    type: u2
    if: (flags & 4096) != 0
  - id: sling_registry_id
    type: u2
    if: (flags & 8192) != 0
  - id: stock_registry_id
    type: u2
    if: (flags & 16384) != 0
  - id: canon_registry_id
    type: u2
    if: (flags & 32768) != 0
  - id: explosion_timer
    type: s4
    if: (flags & 65536) != 0
  - id: max_angle
    type: f4
    if: (flags & 131072) != 0
  - id: blood_level
    type: f4
    if: (flags & 262144) != 0
  - id: weapon_sprite
    type: common::string_utf
    if: (flags & 4194304) != 0
instances:
  contains_clip:
    value: (flags & 524288) != 0
  round_chambered:
    value: (flags & 1048576) != 0
  jammed:
    value: (flags & 2097152) != 0
