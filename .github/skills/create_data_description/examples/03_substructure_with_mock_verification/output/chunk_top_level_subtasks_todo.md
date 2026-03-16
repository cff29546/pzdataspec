# chunk_top_level_subtasks_todo

## Parent task
- Build top-level chunk schema while unresolved `Square` and top-level `Polygon` list details are split as child sub-tasks.

## TODO list
1. Complete `square` with exact structure.
2. Describe `polygon` sub-structure and map its nested rings/vertices.

## Sub-task specification

### ST-01: Square
- Input source code: `../input/ChunkTopLevel.java`
- Entry points: `ChunkTopLevel.Square.save(ByteBuffer bb)` method / `ChunkTopLevel.Square.load(ByteBuffer bb)` method
- Desired output location: inside `chunk_top_level.ksy` (replace mock description with actual in `types.square`)

### ST-02 Polygon
- Input source code: `../input/Polygon.java`
- Entry points: `Polygon.save(ByteBuffer bb)` / `Polygon.load(ByteBuffer bb)`
- Desired output location: update `polygon.ksy`
