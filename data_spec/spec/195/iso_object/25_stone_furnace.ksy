meta:
  id: stone_furnace
  endian: be
# zombie.iso.objects.BSFurnace.load(ByteBuffer, int, boolean)
# Extends IsoObject, calls super.load()
# Factory name: "StoneFurnace", class ID 25
params:
  - id: world_version
    type: u4
  - id: debug
    type: u1
seq:
  - id: fire_started
    type: u1
    doc: "BSFurnace.fireStarted (get() == 1)"
  - id: heat
    type: f4
    doc: "BSFurnace.heat (getFloat())"
  - id: fuel_amount
    type: f4
    doc: "BSFurnace.fuelAmount (getFloat())"
