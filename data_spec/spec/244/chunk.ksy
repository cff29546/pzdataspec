meta:
  id: chunk
  file-extension: bin
  endian: be
  imports:
    - ../common/common
    - inventory
    - erosion
    - base_vehicle
    - grid
    - blood_splat

doc: |
  Binary layout for a chunk data structure (10x10 for B41 or 8x8 for B42)
  Structure derived from IsoChunk.LoadFromDiskOrBufferInternal / IsoChunk.Save and related classes.

seq:
  - id: debug
    type: u1
  - id: world_version
    type: u4
  - id: size
    type: u4
  - id: crc
    type: u8

  # Blending flags
  - id: blending_done_full
    type: u1
    if: world_version >= 209
  - id: blending_modified_mask
    type: u1
    if: world_version >= 210
  - id: blending_done_partial
    type: u1
    if: world_version >= 210
  - id: blending_depth
    type: u1
    repeat: expr
    repeat-expr: 4
    if: world_version >= 210 and blending_done_partial != 0 and blending_modified_mask != 0x0f

  # Attachments state
  - id: attachments_done_full
    type: u1
    if: world_version >= 214
  - id: attachments_state_mask
    type: u1
    if: world_version >= 214
  - id: num_attachments_partial
    type: u2
    if: world_version >= 221
  - id: attachments_partial
    type: square_coord
    repeat: expr
    repeat-expr: num_attachments_partial
    if: world_version >= 221

  - id: raw_max_level
    type: s4
    if: world_version >= 206
  - id: raw_min_level
    type: s4
    if: world_version >= 206

  # Blood splats
  - id: num_blood
    type: s4
  - id: blood
    type: blood_splat::floor
    repeat: expr
    repeat-expr: num_blood

  # Grid squares
  - id: squares
    type: grid::square(world_version, debug)
    repeat: expr
    repeat-expr: block_size * block_size
    if: true

  # Erosion
  - id: erosion
    type: erosion::erosion_chunk

  # Generators
  - id: num_generators
    type: u2
  - id: generators
    type: generator
    repeat: expr
    repeat-expr: num_generators

  # Vehicles
  - id: num_vehicles
    type: u2
  - id: vehicles
    type: vehicle_warp(world_version)
    repeat: expr
    repeat-expr: num_vehicles

  - id: loot_respawn_hour
    type: s4
  - id: num_spawned_rooms
    type:
      switch-on: world_version >= 206
      cases:
        true: u2
        false: u1
  - id: spawned_rooms
    type:
      switch-on: world_version >= 206
      cases:
        true: s8
        false: s4
    repeat: expr
    repeat-expr: num_spawned_rooms

  - id: remainder
    size-eos: true

instances:
  max_level:
    value: 'world_version >= 206 ? raw_max_level : 7'
  min_level:
    value: 'world_version >= 206 ? raw_min_level : 0'
  block_size:
    value: 'world_version > 195 ? 8 : 10'

types:
  # iso.worldgen.utils.SquareCoord.save / load
  square_coord:
    seq:
      - id: x
        type: s4
      - id: y
        type: s4
      - id: z
        type: s4

  generator:
    seq:
      - id: x
        type: s4
      - id: y
        type: s4
      - id: z
        type: s1

  vehicle_warp:
    params:
      - id: world_version
        type: u4
    seq:
      - id: x
        type: s1
      - id: y
        type: s1
      - id: z
        type: s1
      - id: vehicle
        type: base_vehicle(world_version)
