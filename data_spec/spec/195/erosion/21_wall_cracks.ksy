meta:
  id: wall_cracks_data
  endian: be
params:
  - id: world_version
    type: u4
seq:
  # zombie.erosion.categories.WallCracks.CategoryData.load
  - id: game_obj
    type: u1
  - id: spawn_time
    type: u2
  - id: cur_id
    type: s4
  - id: alpha
    type: f4
  - id: has_top
    type: u1
  - id: top
    type: wall_cracks_top
    if: has_top != 0
types:
  wall_cracks_top:
    seq:
      - id: game_obj
        type: u1
      - id: spawn_time
        type: u2
      - id: cur_id
        type: s4
      - id: alpha
        type: f4
