meta:
  id: pushable_object
  endian: be
  imports:
    - iso_object_shared
params:
  - id: world_version
    type: u4
  - id: debug
    type: u1
seq:
  - id: pushable_object
    type: iso_object_shared::iso_pushable_object(world_version,0)
