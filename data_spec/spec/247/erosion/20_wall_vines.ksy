meta:
  id: wall_vines_data
  endian: be
params:
  - id: world_version
    type: u4
seq:
  # zombie.erosion.categories.WallVines.CategoryData.load
  - id: game_obj
    type: u1
  - id: max_stage
    type: u1
  - id: spawn_time
    type: u2
  - id: cur_id
    type: s4
  - id: has_top
    type: u1
  - id: top
    type: wall_vines_top
    if: has_top != 0
types:
  wall_vines_top:
    seq:
      - id: game_obj
        type: u1
      - id: spawn_time
        type: u2
      - id: cur_id
        type: s4
