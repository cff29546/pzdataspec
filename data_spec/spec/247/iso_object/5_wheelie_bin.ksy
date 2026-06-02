meta:
  id: wheelie_bin
  endian: be
  imports:
    - iso_object_shared
params:
  - id: world_version
    type: u4
  - id: debug
    type: u1
seq:
  - id: bin
    type: iso_object_shared::iso_pushable_object(world_version,1)

