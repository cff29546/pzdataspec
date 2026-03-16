# Architecture overview

This document describes the major pipelines in this repository. It intentionally stays high-level; command-by-command instructions are in the quick starts.

## What this repo does

`pzdataspec` maintains Kaitai Struct specifications for Project Zomboid data, compiles them to Python parsers, validates them against real game files, and packages release artifacts for downstream use.

## High-level pipeline

1. Game/source intake
   - Decompile the installed game build and map game build changes to world versions.
2. Data description maintenance
   - Create or update versioned `.ksy` schemas from decompiled read/write logic.
3. Parser build + verification
   - Compile `.ksy` to Python modules and parse representative binary/DB data.
4. Release packaging
   - Bundle runtime parser package + generated specs into zip artifacts.

## Repository structure (major areas)

- `data_spec/spec/common/`: shared Kaitai types reused across versions.
- `data_spec/spec/<world_version>/`: versioned schemas and analysis notes.
- `data_spec/scripts/`: parse/validation scripts (`parse.py`, `parse_db.py`, batch helpers).
- `pzdataspec/`: runtime parser package included in releases.
- `scripts/`: repository-level utilities (including decompilation and release-note generation).

Generated and output files are organized under `output/`:
- `output/decompiled/<world_version>/`: decompiled game source snapshots.
- `output/spec/`: generated Python parsers for local verification.
- `output/release/`: packaged artifacts and release notes.

## Major workflows

### Parsing workflow (consumer path)

Goal: use existing schemas to parse save/game data.

Flow:

1. Configure environment and paths.
2. Build parsers from current schemas.
3. Parse target files (binary and/or SQLite blobs).
4. Run batch validation for broader confidence.

Reference:
- [Quick start: parsing](quick_start_parsing.md)

### Data-description workflow (maintenance path)

Goal: update schemas after format changes introduced by game updates.

Flow:

1. Decompile updated game source.
2. Leverage the AI-assisted workflow (`create_data_description` skill) to derive or update `.ksy` files from source.
3. Compile updated schemas to Python parsers and verify against real data.

Reference:
- [Quick start: data description](quick_start_data_description.md)
- [create_data_description skill](/.github/skills/create_data_description/skill.md)

### Release workflow (distribution path)

Goal: produce distributable parser artifacts per world version.

Flow:

1. Build one/all targets via root release script.
2. Generate/update release notes.
3. Publish as workflow artifact and/or GitHub release.

Execution options:

- Local: `release.bat`
- CI: `.github/workflows/release-artifact.yml` (`workflow_dispatch`)

## Versioning model

- The game has two version systems: build version and world version.
  - Build version is the number displayed in the game launcher and update logs (e.g. 41.78).
  - World version is an internal numeric identifier that increments with each update and is used in save files to determine format (e.g. 195).
  - The version mapping between build versions and world versions is tracked in [version_mapping.yaml](/data_spec/spec/version_mapping.yaml) and updated with each decompilation.
- Since the world version is the primary determinant of save data format, schemas are organized by world version. When a new game update is released, besides updating the version mapping, there are 3 possible scenarios:
    1. The update only bumps the version number without changing save data format. In this case, the spec from the previous version can be reused without changes. We can simply continue using the previous schemas version as it is forward compatible.
    2. The update introduces minor changes to the save data format. After minimal schema updates to accommodate the changes the new schema can be compatible with both the new and old world versions. In this case, we can rename the previous version's schema folder to the new version and apply the necessary updates. This way we maintain a single schema that works for both versions, which saves maintenance effort and repository complexity.
    3. The update introduces major changes to the save data format that are not backward compatible. In this case, we need to create a new schema folder for the new world version and maintain separate schemas for the old and new versions.

## Design principles

- Provide clear, accurate information context (including repo structure, documentation, and analysis notes) to empower AI assistants workflow.
- Provide easy-to-use scripts and tools for both maintenance and downstream use cases, with clear separation of concerns.

## Related docs

- [Quick start: parsing](quick_start_parsing.md)
- [Quick start: data description](quick_start_data_description.md)