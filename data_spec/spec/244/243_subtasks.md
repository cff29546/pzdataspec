# Version 243 sub-task specification

## Sub-task 1 (completed): establish concrete serializer anchors
- **Input sources**:
  - [output/decompiled/243/zombie/characters/IsoGameCharacter.java](../../output/decompiled/243/zombie/characters/IsoGameCharacter.java)
  - [output/decompiled/243/zombie/characters/IsoPlayer.java](../../output/decompiled/243/zombie/characters/IsoPlayer.java)
  - [output/decompiled/243/zombie/characters/IsoZombie.java](../../output/decompiled/243/zombie/characters/IsoZombie.java)
  - [output/decompiled/243/zombie/characters/IsoSurvivor.java](../../output/decompiled/243/zombie/characters/IsoSurvivor.java)
- **Entry points**:
  - `IsoGameCharacter.load/save`
  - `IsoPlayer.load/save`
  - `IsoZombie.load/save`
- **Output targets**:
  - [iso_object/1_player.ksy](iso_object/1_player.ksy)
  - [iso_object/2_survivor.ksy](iso_object/2_survivor.ksy)
  - [iso_object/3_zombie.ksy](iso_object/3_zombie.ksy)

## Sub-task 2 (completed): model nested substructures used by class IDs 1/2/3
- **Input sources**:
  - [output/decompiled/243/zombie/characters/Stats.java](../../output/decompiled/243/zombie/characters/Stats.java)
  - [output/decompiled/243/zombie/characters/CharacterStat.java](../../output/decompiled/243/zombie/characters/CharacterStat.java)
  - [output/decompiled/243/zombie/characters/BodyDamage/BodyDamage.java](../../output/decompiled/243/zombie/characters/BodyDamage/BodyDamage.java)
  - [output/decompiled/243/zombie/characters/BodyDamage/Thermoregulator.java](../../output/decompiled/243/zombie/characters/BodyDamage/Thermoregulator.java)
  - [output/decompiled/243/zombie/characters/BodyDamage/Nutrition.java](../../output/decompiled/243/zombie/characters/BodyDamage/Nutrition.java)
  - [output/decompiled/243/zombie/characters/BodyDamage/Fitness.java](../../output/decompiled/243/zombie/characters/BodyDamage/Fitness.java)
  - [output/decompiled/243/zombie/characters/PlayerCheats.java](../../output/decompiled/243/zombie/characters/PlayerCheats.java)
  - [output/decompiled/243/zombie/characters/PlayerCraftHistory.java](../../output/decompiled/243/zombie/characters/PlayerCraftHistory.java)
  - [output/decompiled/243/zombie/characters/traits/CharacterTraits.java](../../output/decompiled/243/zombie/characters/traits/CharacterTraits.java)
  - `IsoGameCharacter.XP.load/save`, `saveKnownMediaLines/loadKnownMediaLines`
- **Output target**:
  - [iso_object/character_shared.ksy](iso_object/character_shared.ksy)

## Sub-task 3 (completed): connect subtype dispatch in top-level iso_object schema
- **Input source**:
  - [output/decompiled/243/zombie/iso/IsoObject.java](../../output/decompiled/243/zombie/iso/IsoObject.java)
- **Entry point**:
  - `IsoObject.factoryFromFileInput` class-id mapping
- **Output target**:
  - [iso_object.ksy](iso_object.ksy)
- **Change delivered**:
  - Enabled imports + switch cases for class IDs `1`, `2`, `3`.

## Sub-task 4 (completed): static schema validation pass
- **Validation actions**:
  - IDE problems check on:
    - [iso_object/character_shared.ksy](iso_object/character_shared.ksy)
    - [iso_object/1_player.ksy](iso_object/1_player.ksy)
    - [iso_object/2_survivor.ksy](iso_object/2_survivor.ksy)
    - [iso_object/3_zombie.ksy](iso_object/3_zombie.ksy)
    - [iso_object.ksy](iso_object.ksy)
- **Result**:
  - No schema errors reported by editor diagnostics.
- **Note**:
  - Terminal build output was not returned by the tooling session, so CLI build confirmation should be re-run locally if needed.