meta:
  id: street_cracks_data
  endian: be
params:
  - id: world_version
    type: u4
seq:
  # zombie.erosion.categories.StreetCracks.CategoryData.load
  - id: game_obj
    type: u1
  - id: max_stage
    type: u1
  - id: spawn_time
    type: u2
  - id: cur_id
    type: s4
  - id: has_grass
    type: u1
