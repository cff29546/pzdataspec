---
name: create_data_description
description: Create and validate Kaitai Struct (.ksy) specifications from serializer/deserializer source code via static analysis and iterative verification.
---

# Skill: create_data_description

## Goal
Infer the exact binary layout implemented by source serializer/deserializer logic and produce complete, compilable Kaitai Struct specs that are reliable for Project Zomboid data parsing pipelines.

## Primary use case in this repo
Use this skill to extract `.ksy` descriptions from decompiled Project Zomboid sources so parsed output can support downstream map-overlay rendering workflows.

## When to use
- You have decompiled or source-level serdes code and need a precise `.ksy`.
- You need to update existing `.ksy` files to match format changes in a newer world version.
- You need to investigate parser failures caused by version gates, dynamic structures, or polymorphic records.

## Inputs (expected)
- Serializer/deserializer source code.
- Entry points if known (method/function/class names).
- Target world version or game build when available.
- Optional sample binary files for verification.
- Optional prior `.ksy` files from nearby versions for reference.

## Required outputs
1. Data description `.ksy` file(s).
2. Source analysis markdown: `<name>_analysis.md` (create or update).
3. Type index update (mapping source types/classes to `.ksy` types and file locations).
4. Sub-tasks specification update (if applicable). Including input source code and entry points and desired output locations for each sub-task. See examples [Example 3](examples/03_substructure_with_mock_verification) and [Example 5](examples/05_polymorphic_dispatch_table) for reference.

## Working approach

### Macro level (top-down)
- Start from a true top-level entry point and maintain a call graph.
- Track common/shared types across the format (common type reference).
- Split work into sub-tasks by independent sub-structures.
- Keep explicit links between parent structures and delegated reads.

### Micro level (field-accurate)
- Determine endianness from actual read/write APIs and buffer order.
- Determine primitive type and signedness directly from serialization methods.
- Preserve exact read/write order from source logic.
- Model conditions, loops, switches, and version gates exactly as implemented.

## Tips

### Analysis
- Make sure to check the [Examples Overview](examples/README.md) for reference implementations of common patterns.
- Surface uncertainty explicitly in the analysis markdown.

### Verification
- Verification is important and you need data to verify against. If you don't have data, ASK the developer working with you to play the game and generate some. A good save game for testing should include a variety kind of game objects (e.g. dead zombies, dead animals, player built structures, etc.). ASK explicitly for uncovered code paths.

If verification data exists:
- Compile `.ksy` with `data_spec/build.bat`.
- Run parser scripts over provided samples and inspect failures.
  - For binary files, use: `python data_spec/scripts/parse.py <spec_name> <bin_file> -o <output_path>`
    - See `data_spec/scripts/test_chunks.bat` for example
  - For sqlite3 db files, use: `python data_spec/scripts/parse_db.py <spec_name> <db_file> <table_name> -o <output_path> -d <data_field> [-a <param_fields>]`.
    - See `data_spec/scripts/test_vehicles.bat` for example

Recommended loop:
1. Build target schema(s), ensuring they compile.
2. Parse representative files.
3. Reconcile first failing offset with source read order.
4. Update schema and repeat.

### Debugging

1. Adding `valid` checks to help locate issue
Kaitai Struct error messages might be hard to locate if the error is far after the misalignment point. Adding `valid` checks on fields with known tight constraints can help surface the error closer to the source of misalignment.
2. Verification with top-level specs with sub-structures masked
You may mask out sub-structures with a known length to verify the parent-level layout and alignment first. See [Example 3](examples/03_substructure_with_mock_verification) for an example of this approach.

### Documentation
- Update `<name>_analysis.md` with final call graph, unresolved items, and rationale.
- Update `<name>_type_index.md` mapping source classes/methods to `.ksy` types.

Simple `<name>_type_index.md` format example:

```md
# chunk_type_index
| Source type / method | Source location | KSY type / field | KSY file | Resolved | Notes |
| --- | --- | --- | --- | --- | --- |
| `zombie.iso.IsoChunk#load(ByteBuffer,int,boolean)` | `zombie/iso/IsoChunk.java` | `chunk` | `chunk.ksy` | Yes | Entry point for chunk loading |
| `zombie.iso.areas.IsoRoom#load(ByteBuffer,int)` | `zombie/iso/areas/IsoRoom.java` | `types.room` | `chunk.ksy` | Yes | Repeated in room list |
```

The `Resolved` column should be either `Yes`, `No` or `Partial`.

## Project-specific conventions

- Place final `.ksy` specs under `data_spec/spec/<ver>/` to match the existing directory hierarchy.

### Style and naming
- Follow naming conventions used in this repository (for example `num_*` for counts and `len_*` for byte lengths).
- Use snake_case for identifiers: `meta.id`, field IDs, and type names
- Define shared primitives as reusable `.ksy` types and import them via `imports`. See `data_spec/spec/common/common.ksy` for examples.

### Game Logic
- Decompiled game code is in `output/decompiled/<version>/`. It's not version-controlled but can be generated by running `scripts\decompile_game.bat` from the repo root.
- Model world-version gates explicitly; load logic often depends on `world_version` while save paths may only write latest format.
- Common objects and entry points:
  - `IsoChunk` represents a single binary file from save data (typically a 10x10 or 8x8 tile area). Its serialization logic is in `zombie.iso.IsoChunk.LoadFromDisk` and `zombie.iso.IsoChunk.Save` methods, found in `output/decompiled/<version>/zombie/iso/IsoChunk.java`. This is the primary parser target for the project, and the most complex one.
  - `zombie.iso.IsoWorld.LoadTileDefinitions` is responsible for loading tile definitions from `tiledef` files.
  - `zombie.iso.IsoLot.Load` is responsible for loading map data from `.lotpack` files.
  - `zombie.iso.IsoMetaGrid.MetaGridLoaderThread.loadCell` is responsible for loading map cell, including header information from `.lotheader` files.