meta:
  id: world_inventory_object
  endian: be
  imports:
    - ../../common/common
    - ../inventory
params:
  - id: world_version
    type: u4
  - id: debug
    type: u1
seq:
  # NOTE: IsoWorldInventoryObject does NOT call super.load()
  # zombie.iso.objects.IsoWorldInventoryObject.load(ByteBuffer, int, boolean)
  - id: xoff
    type: f4
    doc: "IsoWorldInventoryObject.xoff"
  - id: yoff
    type: f4
    doc: "IsoWorldInventoryObject.yoff"
  - id: zoff
    type: f4
    doc: "IsoWorldInventoryObject.zoff"
  - id: offset_x
    type: f4
    doc: "var4 (offsetX in save)"
  - id: offset_y
    type: f4
    doc: "var5 (offsetY in save)"
  - id: item
    type: inventory::sized_blob(world_version)
    doc: "InventoryItem.loadItem(var1, var2)"
  - id: drop_time
    type: f8
    doc: "IsoWorldInventoryObject.dropTime (v>=108, always true at v195)"
  - id: bit_flags
    type: u1
    if: world_version >= 193
