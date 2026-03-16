meta:
  id: tile_def
  endian: le
  imports:
    - ../common/common
  # zombie.iso.IsoWorld.LoadTileDefinitions(IsoSpriteManager sprMan, String filename, int fileNumber)
seq:
  - id: magic
    size: 4
    contents: tdef
  - id: version
    type: u4
  - id: num_tile_sheets
    type: u4
  - id: tile_sheets
    type: tile_sheet
    repeat: expr
    repeat-expr: num_tile_sheets

types:
  # One tilesheet entry. Strings are LF-terminated (0x0A), no CR.
  tile_sheet:
    doc: |
      Corresponds to one tilesheet block read in LoadTileDefinitions:
      - name (line-terminated string), then image_name
      - dimensions in tiles (w, h)
      - tileset_number
      - num_tiles records follow
    seq:
      - id: name
        type: common::string_l
      - id: image_name
        type: common::string_l
      - id: w_tiles
        type: u4
      - id: h_tiles
        type: u4
      - id: tileset_number
        type: u4
      - id: num_tiles
        type: u4
      - id: tiles
        type: tile
        repeat: expr
        repeat-expr: num_tiles

  # One tile entry: a list of property pairs (name, value), both LF-terminated.
  tile:
    seq:
      - id: num_properties
        type: u4
      - id: properties
        type: property
        repeat: expr
        repeat-expr: num_properties

  property:
    seq:
      - id: name
        type: common::string_l
      - id: value
        type: common::string_l

doc: |
  Tile definition files used by Project Zomboid to describe sprite properties.
  Parsed by IsoWorld.LoadTileDefinitions / LoadTileDefinitionsPropertyStrings.

  Notes:
  - Strings are LF (0x0A) terminated; CR (0x0D) is not used.
  - Property names and values are read as lines; the game may trim whitespace.
  - Patch tiles files (".patch.tiles") are read with the same structure, but
    the game code may skip tile entries for missing sprites; this schema
    models the base format without filename-dependent skipping.