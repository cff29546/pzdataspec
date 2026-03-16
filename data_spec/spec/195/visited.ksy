meta:
  id: visited
  endian: be

doc: |
  World Map Visited file (map_visited.bin).
  zombie.worldMap.WorldMapVisited.save / load
  for each unit, flag bit 1 means visited, bit 2 means known.

  in version 2 (world_version >= 234), each unit uses 2 bits
  units_per_cell is 8 (e.g. each unit is 32x32 squares)
  cell range is fixed [-250, 250] in both x and y directions.
  see zombie.iso.worldgen.WorldGenParams.minXCell, maxXCell, minYCell, maxYCell

  in version 1, each unit is stored as 1 byte.
  for B41, units_per_cell is 10 (each unit is 30x30 squares).
  cell range is actual map cell range ([0, 66] for x and [0, 52] for y)

seq:
  - id: world_version
    type: u4
  - id: min_x
    type: s4
  - id: min_y
    type: s4
  - id: max_x
    type: s4
  - id: max_y
    type: s4
  - id: units_per_cell
    type: u4
  - id: data
    size: len_data
  - id: remaining
    size-eos: true

instances:
  version:
    value: 1
  width_in_cells:
    value: max_x - min_x + 1
  height_in_cells:
    value: max_y - min_y + 1
  units:
    value: width_in_cells * height_in_cells * units_per_cell * units_per_cell
  len_data:
    value: units