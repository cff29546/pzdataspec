meta:
  id: grid
  endian: be
  imports:
    - ../common/common
    - inventory
    - erosion
    - blood_splat
    - iso_object

types:
  # a square coordnate with all levels of grid squares
  square:
    params:
      - id: world_version
        type: u4
      - id: debug
        type: u1
    seq:
      - id: flags64
        type: common::bit_mask_be(8)
        if: world_version >= 206
      - id: flags8
        type: common::bit_mask_be(1)
        if: world_version < 206
      - id: squares
        type: grid_square(world_version, debug)
        repeat: expr
        repeat-expr: num_squares
    instances:
      layer_flags:
        value: '(world_version >= 206) ? flags64.flags : (flags8.flags.as<u8> * 4294967296)'
      bits:
        value: '(world_version >= 206) ? flags64.bits : flags8.bits'
      num_squares:
        value: bits

  # iso.IsoGridSquare.save / load
  grid_square:
    params:
      - id: world_version
        type: u4
      - id: debug
        type: u1
    seq:
      - id: erosion
        type: erosion::erosion_square(world_version)
      - id: flags
        type: u1
      - id: debug_info_objects
        type: common::string_utf
        if: (flags & 1) != 0 and debug != 0
      - id: raw_objects_count
        type: u2
        if: (flags & 1) != 0 and (flags & 8) != 0
      - id: objects
        type: object_with_debug(world_version, debug)
        repeat: expr
        repeat-expr: num_objects
      - id: debug_signature
        size: 4
        contents: CRPS
        if: (flags & 1) != 0 and debug != 0
      - id: extra
        type: grid_square_extra_data(world_version, debug)
        if: (flags & 64) != 0
      - id: vis
        type: u1
    instances:
      num_objects:
        value: '(flags & 1) == 0 ? 0 :
                (flags & 2) != 0 ? 2 :
                (flags & 4) != 0 ? 3 :
                (flags & 8) != 0 ? raw_objects_count : 1'

  grid_square_extra_data:
    params:
      - id: world_version
        type: u4
      - id: debug
        type: u1
    seq:
      - id: flags
        type: u1
      - id: debug_info_number_of_bodies
        type: common::string_utf
        if: (flags & 1) != 0 and debug != 0
      - id: num_bodies
        type: u2
        if: (flags & 1) != 0
      - id: bodies
        type: dead_body_with_debug(world_version, debug)
        repeat: expr
        repeat-expr: num_bodies
        if: (flags & 1) != 0
      - id: table
        type: common::ktable
        if: (flags & 2) != 0
      - id: trap_position_x
        type: s4
        if: (flags & 8) != 0
      - id: trap_position_y
        type: s4
        if: (flags & 8) != 0
      - id: trap_position_z
        type: s4
        if: (flags & 8) != 0

  dead_body_with_debug:
    params:
      - id: world_version
        type: u4
      - id: debug
        type: u1
    seq:
      - id: debug_info
        type: common::string_utf
        if: debug != 0
      - id: dead_body
        type: iso_object(world_version, debug)
        valid:
          # must be IsoDeadBody (11)
          expr: _.class_id == 11

  object_with_debug:
    params:
      - id: world_version
        type: u4
      - id: debug
        type: u1
    seq:
      - id: object_size
        type: s4
        if: debug != 0
      - id: flags
        type: u1
      - id: object_class_name
        type: common::string_utf
        if: debug != 0
      - id: object
        type: iso_object(world_version, debug)
    instances:
      is_special:
        value: (flags & 2) != 0
      is_world:
        value: (flags & 4) != 0

