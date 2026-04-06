# 245 Analysis (Complete)

## Scope
- Target format: Build 42.16 (`world_version = 245`)
- Primary chunk entry points:
  - `zombie.iso.IsoChunk#LoadFromDiskOrBufferInternal(ByteBuffer)`
  - `zombie.iso.IsoChunk#Save(ByteBuffer, CRC32, boolean)`
- Primary object/character entry points:
  - `zombie.iso.IsoObject#factoryFromFileInput(IsoCell, ByteBuffer)`
  - `zombie.characters.IsoGameCharacter#load/save`
  - `zombie.characters.IsoPlayer#load/save`
  - `zombie.characters.IsoZombie#load/save`
  - `zombie.characters.animals.IsoAnimal#load/save`

## Source Anchors
- Chunk and square flow:
  - `output/decompiled/245/zombie/iso/IsoChunk.java`
  - `output/decompiled/245/zombie/iso/IsoGridSquare.java`
- Object dispatch:
  - `output/decompiled/245/zombie/iso/IsoObject.java`
- Character payloads:
  - `output/decompiled/245/zombie/characters/IsoGameCharacter.java`
  - `output/decompiled/245/zombie/characters/IsoPlayer.java`
  - `output/decompiled/245/zombie/characters/IsoZombie.java`
  - `output/decompiled/245/zombie/characters/IsoSurvivor.java`
  - `output/decompiled/245/zombie/characters/Stats.java`
  - `output/decompiled/245/zombie/characters/CharacterStat.java`
  - `output/decompiled/245/zombie/characters/BodyDamage/BodyDamage.java`
  - `output/decompiled/245/zombie/characters/BodyDamage/Thermoregulator.java`
  - `output/decompiled/245/zombie/characters/BodyDamage/Nutrition.java`
  - `output/decompiled/245/zombie/characters/BodyDamage/Fitness.java`
  - `output/decompiled/245/zombie/characters/PlayerCheats.java`
  - `output/decompiled/245/zombie/characters/PlayerCraftHistory.java`
  - `output/decompiled/245/zombie/characters/traits/CharacterTraits.java`
- Animal payloads in chunk objects:
  - `output/decompiled/245/zombie/iso/objects/IsoHutch.java`
  - `output/decompiled/245/zombie/characters/animals/IsoAnimal.java`

## High-Level Findings
- `IsoChunk` top-level binary sequence is unchanged from 244 to 245.
- Chunk header now writes `world_version = 245`, and loader rejects versions `> 245`.
- Object class dispatch table is unchanged structurally; class IDs still include `1/2/3` for `Player/Survivor/Zombie`.
- Character payload model from prior work remains valid in 245.
- Confirmed 245-specific nested payload change: `IsoAnimal` appends/reads `isWild` at `world_version >= 245`.

## Call Graph (Load)
1. `IsoChunk.LoadFromDiskOrBufferInternal`
2. `IsoGridSquare.load`
3. `IsoObject.factoryFromFileInput` (serialized header + class ID)
4. `IsoObject.load` or overridden subclass loaders
5. For class-specific data:
   - Character branch: `IsoGameCharacter.load` then `IsoPlayer.load` / `IsoZombie.load`
   - Hutch branch: `IsoHutch.load` -> nested `IsoAnimal.load`

## Call Graph (Save)
1. `IsoChunk.Save`
2. `IsoGridSquare.save`
3. Object `save` methods by class ID
4. Nested class payloads, including `IsoAnimal.save` from hutch/nest-box paths

## Field-Level Findings
### Chunk header and core sections
- Sequence remains: `debug`, `world_version`, `size`, `crc`, blending/attachment gates, blood list, square blocks, erosion, generators, vehicles, spawn-room section.
- Version gates observed in chunk loader remain anchored at historical thresholds (`206`, `209`, `210`, `214`, `221`), with no new 245-only top-level branch.

### Object dispatch and polymorphism
- `IsoObject` factory map still registers class IDs `0..41` with gaps as before.
- Character IDs:
  - `1`: `IsoPlayer`
  - `2`: `IsoSurvivor`
  - `3`: `IsoZombie`
- Current schema implementation models:
  - ID `1` via `iso_object/1_player.ksy`
  - ID `3` via `iso_object/3_zombie.ksy`
  - shared game-character base via `iso_object/character_shared.ksy`
- Note: ID `2` exists in source dispatch but does not currently have a dedicated `iso_object/2_survivor.ksy` file in `spec/245`.

### Character shared payload
- `IsoGameCharacter.load/save` ordering in 245 matches existing shared layout assumptions:
  - descriptor/visual/inventory
  - non-zombie branch for `stats`, `body_damage`, `xp`, hand indices
  - status effects and read-book/recipe blocks
  - version-gated cheats/media fields (`>=202`, `>=217`, `>=222`, `>=230`, `>=231`)
- `Stats` still serializes `CharacterStat.ORDERED_STATS` fixed-length 24-float array.
- `BodyDamage` and `Thermoregulator` version gates remain unchanged for 245 relative to established 243+ modeling.

### Player and zombie tails
- `IsoPlayer` tail remains aligned with existing schema:
  - worn-items indices, nutrition, flags, vehicle snapshot, mechanics map, fitness, media lines, voice type, craft history.
  - gates include `auto_drink` (`>=239`), voice (`>=203`), craft history (`>=228`).
- `IsoZombie` tail remains: `loaded_file_version`, `time_since_seen_flesh`, `state_flags`, worn-item list.

### Animal payload (245 delta)
- `IsoAnimal.save` always writes `petTimer`, then writes `isWild` byte.
- `IsoAnimal.load` reads:
  - `petTimer` only when `worldVersion >= 236`
  - `isWild` only when `worldVersion >= 245`
- This is the only confirmed 245-specific serialized field change in the analyzed chunk/object path.

## Schema Coverage Summary
- Chunk-level schema: `data_spec/spec/245/chunk.ksy` and `grid.ksy` remain valid for top-level 245 layout.
- Object dispatch schema: `data_spec/spec/245/iso_object.ksy` remains structurally valid for 245 class table.
- Character schemas: `data_spec/spec/245/iso_object/character_shared.ksy`, `1_player.ksy`, and `3_zombie.ksy` match 245 source behavior.
- Animal schema: `data_spec/spec/245/animal.ksy` includes required 245 `is_wild` field gate.

## Open Items / Risks
- Survivor class (`class_id = 2`) is present in source factory registration but not mapped to a concrete subtype file in `spec/245`; parser behavior currently depends on base/shared handling only.
- No runtime verification was executed in this pass; conclusions are static-analysis based.

## Suggested Verification
1. Build schema set: `data_spec\\build.bat 245`
2. Parse representative chunks including ranch/hutch content.
3. Confirm no offset drift around nested `animal` objects (especially near `pet_timer` / `is_wild`).
