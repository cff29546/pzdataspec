meta:
  id: trees_data
  endian: be
params:
  - id: world_version
    type: u4
seq:
  # zombie.erosion.categories.NatureTrees.CategoryData.load
  - id: game_obj
    type: u1
  - id: max_stage
    type: u1
  - id: spawn_time
    type: u2