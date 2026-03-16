meta:
  id: lotheader
  title: Project Zomboid LotHeader
  endian: le
  file-extension: lotheader
  imports:
    - ../common/common

doc: |
  LotHeader files used by Project Zomboid to describe cell metadata.
  - Version 0 (B41) and Version 1 (B42) supported.

seq:
  # Conditionally consume the magic if present
  - id: magic
    size: 4
    contents: LOTH
    if: has_magic

  - id: version
    type: s4

  - id: num_tiles
    type: s4

  - id: tiles
    type: common::string_l
    repeat: expr
    repeat-expr: num_tiles

  # Version 0 has one padding byte after tiles
  - id: v0_padding
    type: u1
    if: version == 0

  - id: block_width
    type: s4
  - id: block_height
    type: s4

  # Layer bounds differ by version
  - id: min_layer_v1
    type: s4
    if: version == 1
  - id: max_layer_v1
    type: s4
    if: version == 1

  - id: max_layer_v0_plus1
    type: s4
    if: version == 0

  - id: num_rooms
    type: s4

  - id: rooms
    type: room
    repeat: expr
    repeat-expr: num_rooms

  - id: num_buildings
    type: s4

  - id: buildings
    type: building
    repeat: expr
    repeat-expr: num_buildings

  - id: zombie_intensity
    size: cell_in_blocks * cell_in_blocks

instances:
  # Peek first 4 bytes of the file to detect optional magic
  magic_peek:
    pos: 0
    type: str
    size: 4
    encoding: ASCII

  has_magic:
    value: magic_peek == 'LOTH'

  # Unified min/max layer values as interpreted in code
  min_layer:
    value: 'version == 0 ? 0 : min_layer_v1'
  max_layer:
    value: 'version == 0 ? (max_layer_v0_plus1 - 1) : max_layer_v1'

  cell_in_blocks:
    value: 'version == 0 ? 30 : 32'

types:
  room:
    seq:
      - id: name
        type: common::string_l
      - id: level
        type: s4
      - id: num_rects
        type: s4
      - id: rects
        type: rect
        repeat: expr
        repeat-expr: num_rects
      - id: num_objects
        type: s4
      - id: objects
        type: room_object
        repeat: expr
        repeat-expr: num_objects

  rect:
    seq:
      - id: x
        type: s4
      - id: y
        type: s4
      - id: w
        type: s4
      - id: h
        type: s4

  room_object:
    seq:
      - id: type_id
        type: s4
      - id: x
        type: s4
      - id: y
        type: s4

  building:
    seq:
      - id: num_room_indices
        type: s4
      - id: room_indices
        type: s4
        repeat: expr
        repeat-expr: num_room_indices

