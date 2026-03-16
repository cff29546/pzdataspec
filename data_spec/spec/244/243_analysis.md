# Version 243 character data description analysis

## Scope completed
- Implemented class IDs `1` (`IsoPlayer`), `2` (`IsoSurvivor`), and `3` (`IsoZombie`) for [iso_object.ksy](iso_object.ksy).
- Added concrete subtype files:
  - [iso_object/1_player.ksy](iso_object/1_player.ksy)
  - [iso_object/2_survivor.ksy](iso_object/2_survivor.ksy)
  - [iso_object/3_zombie.ksy](iso_object/3_zombie.ksy)
- Added shared nested-structure schema used by all three classes:
  - [iso_object/character_shared.ksy](iso_object/character_shared.ksy)

## Decompiled source anchors
- [output/decompiled/243/zombie/characters/IsoGameCharacter.java](../../output/decompiled/243/zombie/characters/IsoGameCharacter.java)
  - `load(ByteBuffer,int,boolean)` / `save(ByteBuffer,boolean)` for shared character payload.
  - `XP.load` / `XP.save` for XP sub-structure.
  - `loadKnownMediaLines` / `saveKnownMediaLines`.
- [output/decompiled/243/zombie/characters/IsoPlayer.java](../../output/decompiled/243/zombie/characters/IsoPlayer.java)
  - `load(ByteBuffer,int,boolean)` / `save(ByteBuffer,boolean)` for player-specific tail.
- [output/decompiled/243/zombie/characters/IsoZombie.java](../../output/decompiled/243/zombie/characters/IsoZombie.java)
  - `load(ByteBuffer,int,boolean)` / `save(ByteBuffer,boolean)` for zombie-specific tail and flags.
- [output/decompiled/243/zombie/characters/BodyDamage/BodyDamage.java](../../output/decompiled/243/zombie/characters/BodyDamage/BodyDamage.java)
  - `load` / `save` body-part loop + main fields + optional thermoregulator.
- [output/decompiled/243/zombie/characters/BodyDamage/Thermoregulator.java](../../output/decompiled/243/zombie/characters/BodyDamage/Thermoregulator.java)
  - `load` / `save` thermoregulator nodes and version gates (241/243).
- [output/decompiled/243/zombie/characters/Stats.java](../../output/decompiled/243/zombie/characters/Stats.java)
  - ordered stat float array.
- [output/decompiled/243/zombie/characters/CharacterStat.java](../../output/decompiled/243/zombie/characters/CharacterStat.java)
  - `ORDERED_STATS` count used for stats length (`24`).
- [output/decompiled/243/zombie/characters/BodyDamage/Nutrition.java](../../output/decompiled/243/zombie/characters/BodyDamage/Nutrition.java)
  - nutrition load/save scalar layout.
- [output/decompiled/243/zombie/characters/BodyDamage/Fitness.java](../../output/decompiled/243/zombie/characters/BodyDamage/Fitness.java)
  - fitness map/list blocks.
- [output/decompiled/243/zombie/characters/PlayerCheats.java](../../output/decompiled/243/zombie/characters/PlayerCheats.java)
  - cheats list encoding.
- [output/decompiled/243/zombie/characters/PlayerCraftHistory.java](../../output/decompiled/243/zombie/characters/PlayerCraftHistory.java)
  - craft-history UTF-16 char-array key format.
- [output/decompiled/243/zombie/characters/traits/CharacterTraits.java](../../output/decompiled/243/zombie/characters/traits/CharacterTraits.java)
  - known-traits list used by XP payload.

## Notes
- `IsoSurvivor` has no custom load/save override in v243; it uses `IsoGameCharacter` payload only.
- `IsoZombie` skips non-zombie `stats/body_damage/xp/hand-index` fields from `IsoGameCharacter` load path.
- Existing shared types were reused where already correct:
  - [visual.ksy](visual.ksy) (`visual::human_visual`)
  - [iso_object/11_dead_body.ksy](iso_object/11_dead_body.ksy) (`survivor_desc`)