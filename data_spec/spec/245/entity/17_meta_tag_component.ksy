meta:
  id: meta_tag_component
  endian: be
  imports:
    - ../../common/common
params:
  - id: world_version
    type: u4
seq:
  # zombie.entity.meta.MetaTagComponent.save / load
  - id: stored_id
    type: u8