# Version 195 sub-task specification

## Sub-task 1 (completed): bootstrap schema set
- **Input sources**: `data_spec/spec/241/*.ksy`
- **Output**: `data_spec/spec/195/*`
- **Goal**: establish broad initial coverage for version-195 folder.

## Sub-task 2 (completed): world dictionary 195-specific schema
- **Input sources**:
  - `output/decompiled/195/zombie/world/DictionaryData.java`
  - `output/decompiled/195/zombie/world/ItemInfo.java`
- **Entry points**:
  - `DictionaryData.loadFromByteBuffer(ByteBuffer)`
  - `DictionaryData.saveToByteBuffer(ByteBuffer)`
  - `ItemInfo.load(...)`
- **Output**: `data_spec/spec/195/world_dictionary.ksy`

## Sub-task 3 (completed): erosion fallback robustness for iterative parse
- **Input sources**:
  - `output/decompiled/195/zombie/erosion/ErosionData.java`
  - `output/decompiled/195/zombie/erosion/categories/*.java`
- **Entry points**:
  - `ErosionData.Square.load(ByteBuffer,int)`
  - `ErosionCategory.loadCategoryData(ByteBuffer,int)`
- **Output**: `data_spec/spec/195/erosion.ksy`

## Sub-task 4 (completed): stabilize chunk/object parsing for world version 195
- **Input sources**:
  - `output/decompiled/195/zombie/iso/IsoGridSquare.java`
  - `output/decompiled/195/zombie/iso/IsoObject.java`
  - related object subclasses under `output/decompiled/195/zombie/iso/objects/`
- **Entry points**:
  - `IsoGridSquare.load(ByteBuffer,int,boolean)`
  - `IsoObject.factoryFromFileInput(...)`
  - `IsoObject.load(...)` and subclass overrides used in square/static-moving-object paths
- **Output targets**:
  - `data_spec/spec/195/grid.ksy`
  - `data_spec/spec/195/iso_object.ksy`
  - `data_spec/spec/195/iso_object/*.ksy`
- **Cleanup delivered**:
  - removed class-id mappings `36..41` from `iso_object.ksy`
  - removed unused files `animal.ksy` and `iso_object/{37_feeding_trough,38_hutch,39_animal_track,40_butcher_hook,41_window_frame}.ksy`

## Sub-task 5 (completed): remove unused post-195 branches from shared v195 specs
- **Input sources**:
  - `output/decompiled/195/zombie/vehicles/BaseVehicle.java`
  - `output/decompiled/195/zombie/inventory/InventoryItem.java`
- **Entry points**:
  - `BaseVehicle.load(...)` / `BaseVehicle.save(...)`
  - `InventoryItem.load(...)` / `InventoryItem.save(...)`
- **Output targets**:
  - `data_spec/spec/195/base_vehicle.ksy`
  - `data_spec/spec/195/inventory.ksy`
- **Cleanup delivered**:
  - removed animal/entity imports and corresponding unused branches from v195 schemas.

## Sub-task 6 (completed): post-clean validation
- **Build validation**:
  - `data_spec/build.bat 195`
- **Parse validation**:
  - `data_spec/test.bat test_data/195 c v wd vis`
- **Result**:
  - build succeeded for all v195 top-level schemas;
  - parse outputs generated for chunks, vehicles, world dictionary, and visited.

## Sub-task 7 (pending, data-dependent)
- **Input source**: `test_data/195/metadata.bin` (currently missing)
- **Goal**: validate `metadata.ksy` once sample file is available.

