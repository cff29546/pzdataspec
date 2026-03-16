# chunk_top_level_analysis

## Entry point
- `ChunkTopLevel.save(ByteBuffer bb)`

## Macro call graph
- `ChunkTopLevel.save`
  - writes fixed header
  - writes payload with explicit `len_payload`
  - loops `Square.save` blocks, each prefixed by `len_square_data`
  - loops `Polygon.save` blocks from top-level `polygons` list, each prefixed by `len_polygon_data`
    - polygon contains label gate, ring count, and nested vertex lists

## Sub-task TODO list output
- See `chunk_top_level_subtasks_todo.md` in this folder.
