meta:
  id: iso_object_dispatch_table
  endian: be
  imports:
    - iso_object_dispatch_table/9_radio
    - iso_object_dispatch_table/17_door
    - iso_object_dispatch_table/29_light_switch
    - iso_object_dispatch_table/41_thermostat
doc: |
  Polymorphic record example with dynamic dispatch via class-id table.
  Inspired by IsoObject.initFactory() registration and factoryFromFileInput() dispatch.

seq:
  - id: records
    type: object_record
    repeat: eos

types:
  object_record:
    seq:
      - id: class_id
        type: u1
        valid:
          expr: class_id == 9 or class_id == 17 or class_id == 29 or class_id == 41
      - id: len_payload
        type: u2
        valid:
          min: 1
      - id: payload
        size: len_payload
        type: object_payload(class_id)

  object_payload:
    params:
      - id: class_id
        type: u1
    seq:
      - id: data
        type:
          switch-on: class_id
          cases:
            9: cls_9_radio::radio
            17: cls_17_door::door
            29: cls_29_light_switch::light_switch
            41: cls_41_thermostat::thermostat
