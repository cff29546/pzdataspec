meta:
  id: entity_component
  endian: le
doc: |
  Example for dynamic abstract class dispatch using component_id correspondence.
  Derived from EntitySerializer.Serialize + ComponentTypeTable.IdToType.

seq:
  - id: num_components
    type: u1
  - id: components
    type: component_block
    repeat: expr
    repeat-expr: num_components

types:
  component_block:
    seq:
      - id: len_payload
        type: u4
        valid:
          min: 2
      - id: payload
        size: len_payload
        type: component_payload

  component_payload:
    seq:
      - id: component_id
        type: u2
      - id: data
        type:
          switch-on: component_id
          cases:
            2: fuel_component
            8: sign_component
            _: unknown_component
        doc: |
          Dynamic dispatch table (concrete type correspondence):
            2 -> FuelComponent
            8 -> SignComponent

  fuel_component:
    seq:
      - id: liters
        type: f4

  sign_component:
    seq:
      - id: len_text
        type: u2
        valid:
          max: 1024
      - id: text
        type: str
        size: len_text
        encoding: UTF-8

  unknown_component:
    seq:
      - id: raw
        size-eos: true
