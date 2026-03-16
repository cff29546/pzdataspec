meta:
  id: cls_29_light_switch
  endian: be

types:
  light_switch:
    seq:
      - id: is_on
        type: u1
        valid:
          expr: is_on == 0 or is_on == 1
      - id: watts
        type: u4
