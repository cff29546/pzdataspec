# entity_component_analysis

## Entry point
- `EntitySerializer.Deserialize(BinaryReader reader, uint worldVersion)` / `EntitySerializer.Serialize(List<Component>, BinaryWriter, uint worldVersion)`

## Macro call graph
- `EntitySerializer.Deserialize` / `EntitySerializer.Serialize`
  - component count followed by loop over components
  - for each component:
    - writes block as `[len_block][component_id + component_data]`
    - concrete serialization delegated by runtime type

## Concrete type correspondence
- `ComponentTypeTable.IdToType`
  - `2 -> FuelComponent`
  - `8 -> SignComponent`

## Micro extraction notes
- Endian: little-endian (`BinaryWriter` primitives).
- `len_block` includes `component_id` + concrete payload.
- `component_id` selects parser branch via `switch-on`.
- Unknown ids are preserved as `unknown_component` bytes for forward compatibility.
