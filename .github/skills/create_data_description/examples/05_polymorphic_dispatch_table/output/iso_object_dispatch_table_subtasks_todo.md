# iso_object_dispatch_table_subtasks_todo

## Parent task
- Build polymorphic object record parser with dynamic dispatch via class-id table.

## TODO list
1. Replace thermostat placeholder body (`raw`, `size-eos`) with concrete field-level schema.
2. Derive and model nested `schedule` entry structure from `ThermostatObject.save/load`.
3. Add value constraints for thermostat fields where derivable from source semantics.

## Sub-task specification

### ST-01 Complex subtype extraction (Thermostat)
- Input source code: `../input/IsoObjectFactoryInitSnippet.java`
- Entry points: `ThermostatObject.save`, `ThermostatObject.load`, `TYPE_TABLE`, `loadRecord(...)`
- Current schema state: `output/iso_object_dispatch_table/41_thermostat.ksy` is placeholder-only
- Desired output location: `output/iso_object_dispatch_table/41_thermostat.ksy` (`types.thermostat`, nested `types.schedule_entry`)
- Done condition: thermostat payload is structurally parsed (not raw blob) and remains compatible with root dispatch in `iso_object_dispatch_table.ksy`
