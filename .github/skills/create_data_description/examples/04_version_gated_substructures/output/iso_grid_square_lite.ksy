meta:
  id: iso_grid_square_lite
  endian: be
doc: |
  Example for version-gated nested sub-structures.
  Derived from IsoGridSquareLite.save(..., worldVersion).

params:
  - id: world_version
    type: u4

seq:
  - id: x
    type: u1
    valid:
      max: 255
  - id: y
    type: u1
    valid:
      max: 255
  - id: level
    type: u1
    valid:
      max: 7
  - id: tile_flags
    if: world_version >= 125
    type: u4
  - id: num_objects
    type: u1
  - id: objects
    type: object_ref(world_version)
    repeat: expr
    repeat-expr: num_objects

types:
  object_ref:
    params:
      - id: world_version
        type: u4
    seq:
      - id: object_id
        type: u2
      - id: z
        if: world_version >= 160
        type: u1
        valid:
          max: 7
