meta:
  id: zpop
  endian: be
  imports:
    - ../common/common
params:
  - id: is_virtual
    type: bool
    doc: Whether to parse the virtual-zombie `zpop_virtual.bin` variant instead of the per-cell `zpop_<x>_<y>.bin`. The two formats share the same header layout but differ in the body (32x32 sub-cell grid vs. flat virtual group list).
seq:
  - id: version
    type: u2
  - id: num_strings
    type: u2
    if: version >= 4
    doc: Number of dictionary strings (zone / role / building names) used by zombie records.
  - id: strings
    type: common::string_utf
    repeat: expr
    repeat-expr: num_strings
    if: version >= 4
  - id: field_a
    type: u4
    if: is_virtual == false
    doc: Manager field stored at `+0x30` in the C++ object. Always written. Purpose unknown (likely a global counter / RNG seed associated with this cell's population).
  - id: field_b
    type: u4
    if: is_virtual == false and version >= 3
    doc: Manager field stored at `+0x34` in the C++ object. Written starting in v3; purpose unknown.
  - id: subcells
    type: subcell(version)
    repeat: expr
    repeat-expr: 30 * 30
    if: is_virtual == false
  - id: num_virtual_groups
    type: u4
    if: is_virtual == true
    doc: Number of virtual-group records that follow.
  - id: virtual_groups
    type: virtual_group(version)
    repeat: expr
    repeat-expr: num_virtual_groups
    if: is_virtual == true

types:
  subcell:
    params:
      - id: version
        type: u2
    seq:
      - id: real_zombie_count
        type: u2
        doc: Cached "real" zombie count for this sub-cell (`+0x04` in the C++ struct). Distinct from the number of records that follow.
      - id: num_zombies
        type: u2
        doc: Number of `zombie` records that follow.
      - id: zombies
        type: zombie(version)
        repeat: expr
        repeat-expr: num_zombies
      - id: tail_a
        type: u4
        doc: Trailing manager field at `+0x18` (purpose unknown).
      - id: tail_b
        type: u4
        doc: Trailing manager field at `+0x1c` (purpose unknown).

  zombie:
    params:
      - id: version
        type: u2
    seq:
      - id: pos_a
        type: u4
      - id: pos_b
        type: u4
      - id: heading
        type: s1
      - id: state_index
        type: u1
      - id: flags
        type:
            switch-on: version >= 5
            cases:
                true: u4
                false: u1
      - id: extra
        type: u4
        if: version >= 4

  virtual_group:
    params:
      - id: version
        type: u2
    seq:
      - id: num_zombies
        type: u2
        doc: Number of zombies in this group. Writer clamps this into [1,0x7fff], but loader accepts the stored value as-is.
      - id: group_a
        type:
          switch-on: version >= 6
          cases:
            true: u4
            false: u2
      - id: group_b
        type:
          switch-on: version >= 6
          cases:
            true: u4
            false: u2
      - id: zombies
        type: zombie(version)
        repeat: expr
        repeat-expr: num_zombies