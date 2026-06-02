# 247 Analysis (Complete)

## Scope
- Target format: Build 42.19.0 (`world_version = 247`)
- Baseline: `data_spec/spec/245`
- Primary entry points:
  - `zombie.iso.IsoChunk#LoadFromDiskOrBufferInternal(ByteBuffer)`
  - `zombie.iso.IsoChunk#Save(ByteBuffer, CRC32, boolean)`
  - `zombie.iso.IsoGridSquare#load/save`
  - `zombie.iso.IsoObject#factoryFromFileInput/load/save`
  - `zombie.characters.IsoGameCharacter#load/save`
  - `zombie.characters.IsoPlayer#load/save`
  - `zombie.characters.IsoZombie#load/save`
  - `zombie.characters.animals.IsoAnimal#load/save`
  - `zombie.iso.objects.IsoDeadBody#load/save`

## Source Anchors
- Chunk and square flow:
  - `output/decompiled/42.19.0_247/zombie/iso/IsoChunk.java`
  - `output/decompiled/42.19.0_247/zombie/iso/IsoGridSquare.java`
- Object dispatch:
  - `output/decompiled/42.19.0_247/zombie/iso/IsoObject.java`
- Character and animal payloads:
  - `output/decompiled/42.19.0_247/zombie/characters/IsoGameCharacter.java`
  - `output/decompiled/42.19.0_247/zombie/characters/IsoPlayer.java`
  - `output/decompiled/42.19.0_247/zombie/characters/IsoZombie.java`
  - `output/decompiled/42.19.0_247/zombie/characters/animals/IsoAnimal.java`
  - `output/decompiled/42.19.0_247/zombie/iso/objects/IsoDeadBody.java`
  - `output/decompiled/42.19.0_247/zombie/iso/objects/IsoHutch.java`

## High-Level Findings
- `IsoChunk.Save` writes `world_version = 247`; `LoadFromDiskOrBufferInternal` rejects versions `> 247`.
- The chunk top-level byte sequence is unchanged from 245: debug/version/size/crc, blend and attachment sections, min/max levels, blood, 8x8 square blocks, erosion, generators, vehicles, loot respawn, and spawned rooms.
- Existing character payload gates remain at older thresholds (`>=202`, `>=217`, `>=222`, `>=228`, `>=230`, `>=231`, `>=239`, `>=241`, `>=243`). No new 247-specific player/zombie field was found in the inspected entry points.
- Confirmed 246 serialized change: animal corpses inside `IsoDeadBody` include animal genetics after `animalSize`.
- Confirmed 247-specific serialized change: `IsoAnimal` appends an `onlineID` short after the 245 `isWild` byte.

## Call Graph (Load)
1. `IsoChunk.LoadFromDiskOrBufferInternal`
2. `IsoGridSquare.load`
3. `IsoObject.factoryFromFileInput` (serialized header + class ID)
4. `IsoObject.load` or overridden subclass loaders
5. For class-specific data:
   - Character branch: `IsoGameCharacter.load` then `IsoPlayer.load` / `IsoZombie.load`
   - Animal branch: `IsoAnimal.load`
   - Hutch branch: `IsoHutch.load` -> nested `IsoAnimal.load`

## Field-Level Findings
### Chunk header and core sections
- `IsoChunk.Save` now writes literal `247` in the chunk header.
- `IsoChunk.LoadFromDiskOrBufferInternal` accepts versions up to 247.
- No new 246/247 branch was found in the chunk-level read sequence; relevant gates remain `206`, `209`, `210`, `214`, and `221`.

### Object dispatch and polymorphism
- Existing `IsoObject` dispatch modeling from 245 is retained.
- Animal objects continue to use class ID `36` and bypass the normal base-object payload.
- Survivor class ID `2` remains known in source but still has no dedicated schema subtype in this spec set.

### Character payloads
- `IsoGameCharacter`, `IsoPlayer`, and `IsoZombie` save/load order remains compatible with the 245 schemas in the inspected methods.
- Existing thermoregulator/body-damage gates through 243 remain unchanged.

### Dead body animal-corpse payload (246 delta)
- B42.19 `IsoDeadBody.save` writes animal corpse genetics unconditionally for new saves after `animalType` and `animalSize`.
- B42.19 `IsoDeadBody.load` reads the genetics block only when `worldVersion >= 246`.
- The block is:
  - `num_genes` (`u1`)
  - repeated `AnimalGene` records
  - `num_genetic_disorders` (`u1`)
  - repeated UTF disorder strings
- `data_spec/spec/247/iso_object/11_dead_body.ksy` models this as a `world_version >= 246` block inside `animal_corpse_data`.

### Animal payload (247 delta)
- B42.19 `IsoAnimal.save` writes:
  - `petTimer` (`f4`)
  - `isWild` (`u1`)
  - `onlineID` (`s2`/Java short)
- B42.19 `IsoAnimal.load` reads:
  - `petTimer` only when `worldVersion >= 236`
  - `isWild` only when `worldVersion >= 245`
  - `onlineID` only when `worldVersion >= 247`
- `data_spec/spec/247/animal.ksy` models this as trailing `online_id: s2 if world_version >= 247`.

## Schema Coverage Summary
- `data_spec/spec/247` is derived from the complete 245 schema set.
- Confirmed changed files:
  - `data_spec/spec/247/animal.ksy`
  - `data_spec/spec/247/iso_object/11_dead_body.ksy`
- Version mapping already contains `42.19.0: 247`.

## Verification Notes
- Available sample save: `output/saves/247/Apocalypse/2026-06-02_09-40-00`.
- Useful files include `WorldDictionary.bin`, chunk files under `map/`, `map_animals.bin`, `zpop/`, `apop/`, and sqlite DBs.
- Recommended validation:
  1. Build schema set: `data_spec\\build.bat 247`
  2. Parse `WorldDictionary.bin` with `world_dictionary`.
  3. Parse representative chunk files under `map/`, especially saves containing animal objects or hutch/nest-box contents.

## Open Items / Risks
- The provided sample may not exercise every animal serialization path; `map_animals.bin` is separate from the current chunk schema target, and chunk validation did not confirm an animal corpse genetics instance.
- Survivor class (`class_id = 2`) remains partially modeled, matching the inherited limitation documented for 245.
