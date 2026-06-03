meta:
  id: visual
  endian: be
  imports:
    - ../common/common
types:
  # zombie.core.skinnedmodel.visual.HumanVisual.load / save
  human_visual:
    params:
      - id: world_version
        type: u4
    seq:
      - id: flags1
        type: u1
      - id: hair_color
        type: common::color_rgb
        if: (flags1 & 4) != 0
      - id: beard_color
        type: common::color_rgb
        if: (flags1 & 2) != 0
      - id: skin_color
        type: common::color_rgb
        if: (flags1 & 8) != 0
      - id: body_hair
        type: u1
      - id: skin_texture
        type: u1
      - id: zombie_rot_stage
        type: u1
        if: world_version >= 156
      - id: skin_texture_name
        type: common::string_utf
        if: (flags1 & 64) != 0
      - id: beard_model
        type: common::string_utf
        if: (flags1 & 16) != 0
      - id: hair_model
        type: common::string_utf
        if: (flags1 & 32) != 0
      - id: num_blood
        type: u1
      - id: blood
        type: u1
        repeat: expr
        repeat-expr: num_blood
      - id: num_dirt
        type: u1
        if: world_version >= 163
      - id: dirt
        type: u1
        repeat: expr
        repeat-expr: num_dirt
        if: world_version >= 163
      - id: num_holes
        type: u1
      - id: holes
        type: u1
        repeat: expr
        repeat-expr: num_holes
      - id: num_body_visuals
        type: u1
      - id: body_visuals
        type: item_visual(world_version)
        repeat: expr
        repeat-expr: num_body_visuals
      - id: non_attached_hair
        type: common::string_utf
      - id: flags2
        type: u1
        if: world_version >= 187
      - id: natural_hair_color
        type: common::color_rgb
        if: 'world_version >= 187 and (flags2 & 4) != 0'
      - id: natural_beard_color
        type: common::color_rgb
        if: 'world_version >= 187 and (flags2 & 2) != 0'

  # zombie.core.skinnedmodel.visual.ItemVisual.load / save
  item_visual:
    params:
      - id: world_version
        type: u4
    seq:
      - id: flags1
        type: u1
      - id: full_type
        type: common::string_utf
        if: world_version >= 164
      - id: alternate_model_name
        type: common::string_utf
        if: world_version >= 164
      - id: clothing_item_name
        type: common::string_utf
      - id: tint
        type: common::color_rgb
        if: (flags1 & 1) != 0
      - id: base_texture
        type: u1
        if: (flags1 & 2) != 0
      - id: texture_choice
        type: u1
        if: (flags1 & 4) != 0
      - id: hue
        type: f4
        if: 'world_version >= 146 and (flags1 & 8) != 0'
      - id: decal
        type: common::string_utf
        if: 'world_version >= 146 and (flags1 & 16) != 0'
      - id: num_blood
        type: u1
      - id: blood
        type: u1
        repeat: expr
        repeat-expr: num_blood
      - id: num_dirt
        type: u1
        if: world_version >= 163
      - id: dirt
        type: u1
        repeat: expr
        repeat-expr: num_dirt
        if: world_version >= 163
      - id: num_holes
        type: u1
      - id: holes
        type: u1
        repeat: expr
        repeat-expr: num_holes
      - id: num_basic_patches
        type: u1
        if: world_version >= 154
      - id: basic_patches
        type: u1
        repeat: expr
        repeat-expr: num_basic_patches
        if: world_version >= 154
      - id: num_denim_patches
        type: u1
        if: world_version >= 155
      - id: denim_patches
        type: u1
        repeat: expr
        repeat-expr: num_denim_patches
        if: world_version >= 155
      - id: num_leather_patches
        type: u1
        if: world_version >= 155
      - id: leather_patches
        type: u1
        repeat: expr
        repeat-expr: num_leather_patches
        if: world_version >= 155

  # zombie.core.skinnedmodel.visual.AnimalVisual.load / save
  animal_visual:
    seq:
      - id: skin_texture_name
        type: common::string_utf
      - id: animal_rot_stage
        type: u1
