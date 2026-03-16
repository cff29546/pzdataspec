meta:
  id: erosion
  endian: be
  imports:
    - ../common/common

    # Inherited types
    - erosion/00_trees
    - erosion/01_bush
    - erosion/02_plants
    - erosion/03_generic
    - erosion/10_street_cracks
    - erosion/20_wall_vines
    - erosion/21_wall_cracks
    - erosion/30_flowerbed
types:
  # zombie.erosion.ErosionData.Square.save / load
  erosion_square:
    params:
      - id: world_version
        type: u4
    seq:
      - id: flags
        type: u1
      - id: noise_main_byte
        type: u1
        if: (flags & 1) != 0
      - id: soil
        type: u1
        if: (flags & 1) != 0
      - id: magic_num_byte
        type: u1
        if: (flags & 1) != 0
      - id: raw_region_count
        type: u1
        if: (flags & 1) != 0 and (flags & 64) != 0
      - id: regions
        type: erosion_category(world_version)
        repeat: expr
        repeat-expr: num_regions
    instances:
      num_regions:
        value: '(flags & 1) == 0 ? 0 :
                (flags & 4) != 0 ? 1 :
                (flags & 8) != 0 ? 2 :
                (flags & 16) != 0 ? 3 :
                (flags & 32) != 0 ? 4 :
                (flags & 64) != 0 ? raw_region_count : 0'

  # zombie.erosion.categories.ErosionCategory.Data.save
  # zombie.erosion.categories.ErosionCategory.loadCategoryData
  erosion_category:
    params:
      - id: world_version
        type: u4
    seq:
      - id: region_id
        type: u1
      - id: category_id
        type: u1
      - id: disp_season
        type: u1
      - id: flags
        type: u1
      - id: raw_stage
        type: u1
        if: (flags & 128) != 0
      - id: subclass_data
        type:
          switch-on: subclass_id
          cases:
            # See ErosionCategory.loadCategoryData for subclass ID mappings
            0x0000: trees_data(world_version)
            0x0001: bush_data(world_version)
            0x0002: plant_data(world_version)
            0x0003: generic_data(world_version)
            0x0100: street_cracks_data(world_version)
            0x0200: wall_vines_data(world_version)
            0x0201: wall_cracks_data(world_version)
            0x0300: flowerbed_data(world_version)
            _: empty
    instances:
      stage:
        value: '(flags & 8) != 0 ? 1 :
                (flags & 16) != 0 ? 2 :
                (flags & 32) != 0 ? 3 :
                (flags & 64) != 0 ? 4 :
                (flags & 128) != 0 ? raw_stage : 0'
      subclass_id:
        value: 'region_id.as<u4> << 8 | category_id.as<u4>'

  erosion_chunk:
    seq:
      - id: initialized
        type: u1
      - id: tick_stamp
        type: s4
        if: initialized != 0
      - id: epoch
        type: s4
        if: initialized != 0
      - id: moisture
        type: f4
        if: initialized != 0
      - id: minerals
        type: f4
        if: initialized != 0
      - id: soil
        type: u1
        if: initialized != 0

  empty:
    seq: []