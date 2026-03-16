meta:
  id: character_shared
  endian: be
  imports:
    - ../../common/common
    - ../inventory
    - ../visual
    - iso_object_shared

types:
  game_character_base:
    params:
      - id: world_version
        type: u4
      - id: debug
        type: u1
      - id: is_zombie
        type: u1
    seq:
      - id: iso_moving_object_base
        type: iso_object_shared::iso_moving_object
      - id: has_descriptor
        type: u1
      - id: descriptor
        type: survivor_desc(world_version)
        if: has_descriptor == 1
      - id: visual
        type: visual::human_visual
      - id: inventory
        type: inventory::container(world_version)
      - id: asleep
        type: u1
      - id: force_wake_up_time
        type: f4
      - id: stats
        type: character_stats(world_version)
        if: is_zombie == 0
      - id: body_damage
        type: body_damage(world_version)
        if: is_zombie == 0
      - id: xp
        type: character_xp(world_version)
        if: is_zombie == 0
      - id: left_hand_item_index
        type: s4
        if: is_zombie == 0
      - id: right_hand_item_index
        type: s4
        if: is_zombie == 0
      - id: on_fire
        type: u1
      - id: depress_effect
        type: f4
      - id: depress_first_take_time
        type: f4
      - id: beta_effect
        type: f4
      - id: beta_delta
        type: f4
      - id: pain_effect
        type: f4
      - id: pain_delta
        type: f4
      - id: sleeping_tablet_effect
        type: f4
      - id: sleeping_tablet_delta
        type: f4
      - id: num_read_books
        type: s4
      - id: read_books
        type: read_book
        repeat: expr
        repeat-expr: num_read_books
      - id: reduce_infection_power
        type: f4
      - id: num_known_recipes
        type: s4
      - id: known_recipes
        type: common::string_utf
        repeat: expr
        repeat-expr: num_known_recipes
      - id: last_hour_sleeped
        type: s4
      - id: time_since_last_smoke
        type: f4
      - id: beard_grow_timing
        type: f4
      - id: hair_grow_timing
        type: f4
      - id: unlimited_carry
        type: u1
      - id: build_cheat
        type: u1
      - id: health_cheat
        type: u1
      - id: mechanics_cheat
        type: u1
      - id: movables_cheat
        type: u1
        if: world_version >= 176
      - id: farming_cheat
        type: u1
        if: world_version >= 176
      - id: timed_action_instant_cheat
        type: u1
        if: world_version >= 176
      - id: unlimited_endurance
        type: u1
        if: world_version >= 176
      - id: sneaking
        type: u1
        if: world_version >= 161
      - id: death_drag_down
        type: u1
        if: world_version >= 161

  survivor_desc:
    params:
      - id: world_version
        type: u4
    seq:
      - id: id
        type: s4
      - id: forename
        type: common::string_utf
      - id: surname
        type: common::string_utf
      - id: torso
        type: common::string_utf
      - id: female_i
        type: s4
      - id: character_profession
        type: common::string_utf
      - id: has_extras
        type: s4
      - id: num_extras
        type: s4
        if: has_extras == 1
      - id: extras
        type: common::string_utf
        repeat: expr
        repeat-expr: num_extras
        if: has_extras == 1
      - id: num_xp_boosts
        type: s4
      - id: xp_boosts
        type: xp_boost_entry(world_version)
        repeat: expr
        repeat-expr: num_xp_boosts
    instances:
      is_female:
        value: female_i == 1

  xp_boost_entry:
    params:
      - id: world_version
        type: u4
    seq:
      - id: perk
        type: perk_ref(world_version)
      - id: level
        type: s4

  perk_ref:
    params:
      - id: world_version
        type: u4
    seq:
      - id: perk_name
        type: common::string_utf
        if: world_version >= 152
      - id: perk_index
        type: s4
        if: world_version < 152

  read_book:
    seq:
      - id: full_type
        type: common::string_utf
      - id: already_read_pages
        type: s4

  character_stats:
    params:
      - id: world_version
        type: u4
    seq:
      - id: ordered_stats
        type: f4
        repeat: expr
        repeat-expr: 16
      - id: stress_from_cigarettes
        type: f4
        if: world_version >= 97

  body_damage:
    params:
      - id: world_version
        type: u4
    seq:
      - id: body_parts
        type: body_part(world_version)
        repeat: expr
        repeat-expr: 17
      - id: infection_level
        type: f4
      - id: fake_infection_level
        type: f4
      - id: wetness
        type: f4
      - id: catch_a_cold
        type: f4
      - id: has_a_cold
        type: u1
      - id: cold_strength
        type: f4
      - id: unhappyness_level
        type: f4
      - id: boredom_level
        type: f4
      - id: food_sickness_level
        type: f4
      - id: poison_level
        type: f4
      - id: temperature
        type: f4
      - id: reduce_fake_infection
        type: u1
      - id: health_from_food_timer
        type: f4
      - id: pain_reduction
        type: f4
      - id: cold_reduction
        type: f4
      - id: infection_time
        type: f4
      - id: infection_mortality_duration
        type: f4
      - id: cold_damage_stage
        type: f4
      - id: has_thermoregulator
        type: u1
        if: world_version >= 153
      - id: thermoregulator
        type: thermoregulator
        if: world_version >= 153 and has_thermoregulator == 1

  body_part:
    params:
      - id: world_version
        type: u4
    seq:
      - id: is_bitten
        type: u1
      - id: is_scratched
        type: u1
      - id: is_bandaged
        type: u1
      - id: is_bleeding
        type: u1
      - id: is_deep_wounded
        type: u1
      - id: is_fake_infected
        type: u1
      - id: is_infected
        type: u1
      - id: health
        type: f4
      - id: legacy_unknown_i4
        type: s4
        if: world_version >= 37 and world_version <= 43
      - id: bandage_life
        type: f4
        if: world_version >= 44 and is_bandaged == 1
      - id: is_infected_wound
        type: u1
        if: world_version >= 44
      - id: wound_infection_level
        type: f4
        if: world_version >= 44 and is_infected_wound == 1
      - id: bite_time
        type: f4
        if: world_version >= 44
      - id: scratch_time
        type: f4
        if: world_version >= 44
      - id: bleeding_time
        type: f4
        if: world_version >= 44
      - id: alcohol_level
        type: f4
        if: world_version >= 44
      - id: additional_pain
        type: f4
        if: world_version >= 44
      - id: deep_wound_time
        type: f4
        if: world_version >= 44
      - id: have_glass
        type: u1
        if: world_version >= 44
      - id: get_bandage_xp
        type: u1
        if: world_version >= 44
      - id: stitched
        type: u1
        if: world_version >= 48
      - id: stitch_time
        type: f4
        if: world_version >= 48
      - id: get_stitch_xp
        type: u1
        if: world_version >= 44
      - id: get_splint_xp
        type: u1
        if: world_version >= 44
      - id: fracture_time
        type: f4
        if: world_version >= 44
      - id: is_splint
        type: u1
        if: world_version >= 44
      - id: splint_factor
        type: f4
        if: world_version >= 44 and is_splint == 1
      - id: have_bullet
        type: u1
        if: world_version >= 44
      - id: burn_time
        type: f4
        if: world_version >= 44
      - id: need_burn_wash
        type: u1
        if: world_version >= 44
      - id: last_time_burn_wash
        type: f4
        if: world_version >= 44
      - id: splint_item
        type: common::string_utf
        if: world_version >= 44
      - id: bandage_type
        type: common::string_utf
        if: world_version >= 44
      - id: cut_time
        type: f4
        if: world_version >= 44
      - id: part_wetness
        type: f4
        if: world_version >= 153
      - id: stiffness
        type: f4
        if: world_version >= 167

  thermoregulator:
    seq:
      - id: set_point
        type: f4
      - id: metabolic_rate
        type: f4
      - id: metabolic_target
        type: f4
      - id: body_heat_delta
        type: f4
      - id: core_heat_delta
        type: f4
      - id: thermal_damage
        type: f4
      - id: damage_counter
        type: f4
      - id: num_nodes
        type: s4
      - id: nodes
        type: thermoregulator_node
        repeat: expr
        repeat-expr: num_nodes

  thermoregulator_node:
    seq:
      - id: node_index
        type: s4
      - id: celcius
        type: f4
      - id: skin_celcius
        type: f4
      - id: heat_delta
        type: f4
      - id: primary_delta
        type: f4
      - id: secondary_delta
        type: f4

  character_xp:
    params:
      - id: world_version
        type: u4
    seq:
      - id: traits
        type: character_traits
      - id: total_xp
        type: f4
      - id: level
        type: s4
      - id: lastlevel
        type: s4
      - id: num_xp_entries
        type: s4
      - id: xp_entries
        type: perk_xp_entry(world_version)
        repeat: expr
        repeat-expr: num_xp_entries
      - id: num_legacy_unused_xp_entries
        type: s4
        if: world_version < 162
      - id: legacy_unused_xp_entries
        type: perk_ref(world_version)
        repeat: expr
        repeat-expr: num_legacy_unused_xp_entries
        if: world_version < 162
      - id: num_perk_levels
        type: s4
      - id: perk_levels
        type: perk_level_entry(world_version)
        repeat: expr
        repeat-expr: num_perk_levels
      - id: num_multipliers
        type: s4
      - id: multipliers
        type: perk_multiplier_entry(world_version)
        repeat: expr
        repeat-expr: num_multipliers

  character_traits:
    seq:
      - id: num_known_traits
        type: s4
      - id: known_traits
        type: common::string_utf
        repeat: expr
        repeat-expr: num_known_traits

  perk_xp_entry:
    params:
      - id: world_version
        type: u4
    seq:
      - id: perk
        type: perk_ref(world_version)
      - id: xp
        type: f4

  perk_level_entry:
    params:
      - id: world_version
        type: u4
    seq:
      - id: perk
        type: perk_ref(world_version)
      - id: level
        type: s4

  perk_multiplier_entry:
    params:
      - id: world_version
        type: u4
    seq:
      - id: perk
        type: perk_ref(world_version)
      - id: multiplier
        type: f4
      - id: min_level
        type: s1
      - id: max_level
        type: s1

  worn_item_entry:
    seq:
      - id: body_location
        type: common::string_utf
      - id: item_index
        type: s2

  nutrition_data:
    seq:
      - id: calories
        type: f4
      - id: proteins
        type: f4
      - id: lipids
        type: f4
      - id: carbohydrates
        type: f4
      - id: weight
        type: f4

  mechanics_item_entry:
    seq:
      - id: key
        type: s8
      - id: value
        type: s8

  fitness_data:
    params:
      - id: world_version
        type: u4
    seq:
      - id: num_stiffness_inc
        type: s4
        if: world_version >= 167
      - id: stiffness_inc
        type: map_string_f4
        repeat: expr
        repeat-expr: num_stiffness_inc
        if: world_version >= 167
      - id: num_stiffness_timer
        type: s4
        if: world_version >= 167
      - id: stiffness_timer
        type: map_string_s4
        repeat: expr
        repeat-expr: num_stiffness_timer
        if: world_version >= 167
      - id: num_regularity
        type: s4
        if: world_version >= 167
      - id: regularity
        type: map_string_f4
        repeat: expr
        repeat-expr: num_regularity
        if: world_version >= 167
      - id: num_bodypart_to_inc_stiffness
        type: s4
        if: world_version >= 167
      - id: bodypart_to_inc_stiffness
        type: common::string_utf
        repeat: expr
        repeat-expr: num_bodypart_to_inc_stiffness
        if: world_version >= 167
      - id: num_exe_timer
        type: s4
        if: world_version >= 169
      - id: exe_timer
        type: map_string_s8
        repeat: expr
        repeat-expr: num_exe_timer
        if: world_version >= 169

  map_string_f4:
    seq:
      - id: key
        type: common::string_utf
      - id: value
        type: f4

  map_string_s4:
    seq:
      - id: key
        type: common::string_utf
      - id: value
        type: s4

  map_string_s8:
    seq:
      - id: key
        type: common::string_utf
      - id: value
        type: s8

  already_read_book_entry:
    seq:
      - id: registry_item_id
        type: s2

  known_media_lines_data:
    seq:
      - id: num_guid
        type: s2
      - id: guid
        type: common::string_utf
        repeat: expr
        repeat-expr: num_guid