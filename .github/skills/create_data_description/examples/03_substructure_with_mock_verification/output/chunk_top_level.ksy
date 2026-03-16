meta:
  id: chunk_top_level
  endian: be
  imports:
    - polygon
doc: |
  Example for early macro verification using covered-length mock type
  while child structure details are still unresolved.

seq:
  - id: debug
    type: u1
    valid: 121
  - id: world_version
    type: u4
  - id: len_payload
    type: u4
    valid:
      min: 4
  - id: crc
    type: u4
  - id: payload
    type: payload_block
    size: len_payload

types:
  payload_block:
    seq:
      - id: num_squares
        type: u2
      - id: squares
        type: square_block
        repeat: expr
        repeat-expr: num_squares
      - id: num_polygons
        type: u2
      - id: polygons
        type: polygon_block
        repeat: expr
        repeat-expr: num_polygons

  square_block:
    seq:
      - id: len_square_data
        type: u2
        valid:
          min: 2
      - id: square_data
        type: square
        size: len_square_data

  square:
    seq:
      - id: magic
        size: 2
        contents: [0xAB, 0xCD]
      - id: raw
        size-eos: true
    doc: |
      Mock type for `Square` structure, which is still unresolved.

  polygon_block:
    seq:
      - id: len_polygon_data
        type: u2
        valid:
          min: 8
      - id: polygon_data
        type: polygon::polygon
        size: len_polygon_data