# iso_object_dispatch_table_analysis

## Entry points
- `IsoObjectFactoryInitSnippet.saveRecord(ByteBuffer bb, IsoObjectLike obj)`
- `TYPE_TABLE` static mapping (class id -> concrete object name)

## Macro call graph
- `saveRecord`
  - writes `class_id`
  - writes length-prefixed payload
  - dispatches payload layout by `class_id`

## Dispatch table extraction
- 9 -> `RadioObject`
- 17 -> `DoorObject`
- 29 -> `LightSwitchObject`
- 41 -> `ThermostatObject`

## Current extraction status
- Root dispatch and class-id validation already include id `41`.
- `ThermostatObject` subtype file exists at `output/iso_object_dispatch_table/41_thermostat.ksy` as a placeholder (`raw`, `size-eos: true`).
- Concrete field-level schema for thermostat payload is intentionally unresolved and should be emitted as a sub-task TODO.

## Why this is a good skill example
- Matches real Project Zomboid pattern in `IsoObject.initFactory()` + `factoryFromFileInput()`.
- Demonstrates dynamic abstract/derived dispatch through a type-id correspondence table.
- Demonstrates isolating polymorphic payload into a dedicated `switch-on` type.
- Demonstrates subtype layout split into standalone files under `output/iso_object_dispatch_table/`, similar to `data_spec/spec/241/iso_object/`.
