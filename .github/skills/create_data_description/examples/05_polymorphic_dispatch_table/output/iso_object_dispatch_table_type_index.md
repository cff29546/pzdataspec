# iso_object_dispatch_table_type_index

| Source type / method | Source location | KSY type / field | KSY location | Resolved |
|---|---|---|---|---|
| `IsoObjectFactoryInitSnippet.saveRecord` | `input/IsoObjectFactoryInitSnippet.java` | root (`types.object_record`) | `output/iso_object_dispatch_table.ksy` | Partial (Dispatch Wired) |
| `TYPE_TABLE` / type-id registration | `input/IsoObjectFactoryInitSnippet.java` | `types.object_payload` dispatch | `output/iso_object_dispatch_table.ksy` | Partial (Includes Placeholder id 41) |
| `RadioObject.save` | `input/IsoObjectFactoryInitSnippet.java` | `types.radio` | `output/iso_object_dispatch_table/9_radio.ksy` | Yes |
| `DoorObject.save` | `input/IsoObjectFactoryInitSnippet.java` | `types.door` | `output/iso_object_dispatch_table/17_door.ksy` | Yes |
| `LightSwitchObject.save` | `input/IsoObjectFactoryInitSnippet.java` | `types.light_switch` | `output/iso_object_dispatch_table/29_light_switch.ksy` | Yes |
| `ThermostatObject.save` / `ThermostatObject.load` | `input/IsoObjectFactoryInitSnippet.java` | `types.thermostat` | `output/iso_object_dispatch_table/41_thermostat.ksy` | No (Placeholder Mock Only) |
