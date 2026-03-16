# iso_grid_square_lite_analysis

## Entry points
- `IsoGridSquareLite.save(ByteBuffer bb, int worldVersion)`
- `ObjectRef.save(ByteBuffer bb, int worldVersion)`

## Macro call graph
- `IsoGridSquareLite.save`
  - writes position header fields
  - writes version-gated `tileFlags`
  - writes object count and object sub-structures
- `ObjectRef.save`
  - writes base `objectId`
  - writes version-gated `z`

## Micro extraction notes
- Endian: big-endian (ByteBuffer default in this example).
- `tile_flags` exists only for `world_version >= 125`.
- `object_ref.z` exists only for `world_version >= 160`.
- Array length is explicit (`num_objects`).