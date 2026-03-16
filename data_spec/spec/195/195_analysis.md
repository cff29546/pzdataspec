# Version 195 data description analysis

## Scope completed
- Re-reviewed v195 schemas against decompiled v195 source (`output/decompiled/195/**`).
- Removed unused/newer-version carryovers from the v195 schema set.
- Re-ran build + parser validation on `test_data/195` after cleanup.
- Backported `IsoPlayer`/`IsoZombie` serialization support from v243 structure into v195 with v195-specific field ordering and gates.

## Decompiled source anchors
- `output/decompiled/195/zombie/world/DictionaryData.java`
  - `loadFromByteBuffer(ByteBuffer)` and `saveToByteBuffer(ByteBuffer)` define 195 world dictionary binary layout.
- `output/decompiled/195/zombie/world/ItemInfo.java`
  - `load(...)` / `save(...)` define item flags and mod/module index encoding.
- `output/decompiled/195/zombie/iso/IsoGridSquare.java`
  - `load(ByteBuffer,int,boolean)` confirms square/object/extra flags and branch structure used by chunk parsing.
- `output/decompiled/195/zombie/iso/IsoObject.java`
  - v195 factory registration list ends at class ID 35.
- `output/decompiled/195/zombie/characters/IsoGameCharacter.java`
  - `load(ByteBuffer,int,boolean)` defines shared `IsoGameCharacter` payload used by player/zombie before subclass fields.
- `output/decompiled/195/zombie/characters/IsoPlayer.java`
  - `load(ByteBuffer,int,boolean)` defines v195 player subclass field order (`unknown bytes`, stats, worn items, mechanics/fitness, known media).
- `output/decompiled/195/zombie/characters/IsoZombie.java`
  - `load(ByteBuffer,int,boolean)` defines v195 zombie subclass tail (`float marker`, `TimeSinceSeenFlesh`, fake-dead int, worn items).
- `output/decompiled/195/zombie/characters/BodyDamage/*.java`, `Stats.java`
  - Define v195 body/stats payload used by `IsoGameCharacter`.
- `output/decompiled/195/zombie/vehicles/BaseVehicle.java`
  - `save(...)` / `load(...)` do not include animal payload branches used in newer versions.
- `output/decompiled/195/zombie/inventory/InventoryItem.java`
  - v195 flag set does not include later animal/entity extension payload branches.

## Cleanup delivered
1. **`iso_object.ksy` v195 character dispatch backport**
  - Added class-id mappings for `1: IsoPlayer` and `3: IsoZombie`.
  - Added shared base dispatch selection (`IsoObject` vs `IsoMovingObject` vs `IsoGameCharacter`) using `base_type`.
2. **Added v195 character subtype schemas**
  - `iso_object/character_shared.ksy`: v195-aligned `IsoGameCharacter`/stats/body/xp/fitness structures.
  - `iso_object/1_player.ksy`: v195 `IsoPlayer.load` payload.
  - `iso_object/3_zombie.ksy`: v195 `IsoZombie.load` payload.
3. **Previous cleanup retained**
  - Removed class-id mappings `36..41` from switch dispatch and override logic.
  - Removed imports for obsolete per-class specs.
4. **Removed unused v195 files**
  - `animal.ksy`
  - `iso_object/37_feeding_trough.ksy`
  - `iso_object/38_hutch.ksy`
  - `iso_object/39_animal_track.ksy`
  - `iso_object/40_butcher_hook.ksy`
  - `iso_object/41_window_frame.ksy`
5. **`base_vehicle.ksy` and `inventory.ksy` cleanup**
  - Removed animal/entity imports and corresponding branches not needed for v195.

## Validation status against test_data/195
- ✅ Build: `data_spec/build.bat 195` compiled all top-level v195 schemas.
- ✅ Parse batch: `data_spec/test.bat test_data/195 c v wd vis` completed with no parser errors in `output/parsed/TEST_LOG_ERROR.txt`.
- ✅ Output artifacts produced for chunk maps, `vehicles.db`, world dictionary, and visited map in `output/parsed/195`.

## Remaining gap
- `metadata.ksy` v195 sample validation is still blocked by missing `test_data/195/metadata.bin`.
