meta:
  id: item_literature
  endian: be
  imports:
    - ../../common/common

params:
  - id: context
    type: any
  - id: world_version
    type: u4

# zombie.inventory.types.Literature.save / load
# Extends: InventoryItem
seq:
  - id: flags
    type: u1
  - id: num_pages
    if: (flags & 1) != 0
    type:
      switch-on: num_page_type
      cases:
        0: s1
        1: s2
        2: s4
  - id: already_read
    if: (flags & 1) != 0 and (flags & 8) != 0
    type:
      switch-on: num_page_type
      cases:
        0: s1
        1: s2
        2: s4
  - id: num_custom_pages
    type: s4
    if: (flags & 1) != 0 and (flags & 32) != 0
  - id: custom_pages
    type: common::string_utf
    repeat: expr
    repeat-expr: num_custom_pages
    if: (flags & 1) != 0 and (flags & 32) != 0
  - id: locked_by
    type: common::string_utf
    if: (flags & 1) != 0 and (flags & 64) != 0
instances:
  num_page_type:
    value: '(flags & 1) == 0 ? 0 : ((flags & 2) != 0 ? 1 : ((flags & 4) != 0 ? 2 : 0))'
  can_be_read:
    value: '(flags & 1) != 0 and (flags & 16) != 0'
