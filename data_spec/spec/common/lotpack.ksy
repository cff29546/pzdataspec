meta:
  id: lotpack
  title: Project Zomboid LotPack
  endian: le
  file-extension: lotpack

doc: |
  LotPack files store per-chunk compressed tile data for a cell.

# params:
#   - id: world_version
#     type: s4

seq:
  # Conditionally consume the magic if present
  - id: magic
    size: 4
    contents: LOTP
    if: has_magic

  - id: version_v1
    type: s4
    if: has_magic

  - id: num_entries
    type: u4

  - id: entries
    type: table_entry
    repeat: expr
    repeat-expr: num_entries

instances:
  # Peek first 4 bytes of the file to detect optional magic
  magic_peek:
    pos: 0
    type: str
    size: 4
    encoding: ASCII

  has_magic:
    value: magic_peek == 'LOTP'

  version:
    value: 'has_magic ? version_v1 : 0'

  num_blocks:
    value: num_entries

  blocks:
    type: block(_index)
    repeat: expr
    repeat-expr: num_blocks

types:
  table_entry:
    seq:
      - id: offset
        type: u4
      - id: unused
        size: 4
        contents: [0, 0, 0, 0]

  block:
    params:
      - id: i
        type: u4
    instances:
      index:
        value: i
      offset:
        value: _parent.entries[i].offset
      len_data:
        value: 'i < _parent.num_entries - 1 ? (_parent.entries[i + 1].offset - _parent.entries[i].offset) : (_io.size - _parent.entries[i].offset)'
      data:
        pos: offset
        size: len_data
        type: elements

  elements:
    seq:
      - id: elements
        type: element
        repeat: eos

  element:
    seq:
      - id: count
        type: s4
      - id: skip_count
        type: s4
        if: count == -1
      - id: room_id
        type: s4
        if: count > 1
      - id: tile_indices
        type: s4
        repeat: expr
        repeat-expr: count - 1
        if: count > 1
    instances:
      is_skip:
        value: count == -1
        #if: _root.world_version > 1