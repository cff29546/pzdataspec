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
  Binary layout for a chunk data structure (10x10 for B41)
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
    type: u1
  - id: spawned_rooms
    type: s4
    repeat: expr
    repeat-expr: num_spawned_rooms

  - id: remainder
    size-eos: true

instances:
  max_level:
    value: 7
  min_level:
    value: 0
  block_size:
    value: 10

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
