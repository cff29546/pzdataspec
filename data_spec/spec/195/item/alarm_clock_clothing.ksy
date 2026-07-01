meta:
  id: item_alarm_clock_clothing
  endian: be
  imports:
    - clothing
    - alarm_clock

params:
  - id: context
    type: any
  - id: world_version
    type: u4

# zombie.inventory.types.AlarmClockClothing.save / load
# Extends: Clothing (which extends InventoryItem)
seq:
  - id: clothing
    type: item_clothing(context, world_version)
  - id: alarm_clock
    type: item_alarm_clock(context, world_version)
