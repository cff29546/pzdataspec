# dictionary_data_analysis

## Entry point
- `DictionaryData.load(ByteBuffer bb)` / `DictionaryData.save(ByteBuffer bb)`

## Macro call graph
- `DictionaryData.load` / `DictionaryData.save`
  - header primitives: `numModIds`, `numModules`, `numEntries`
  - `numEntries`-bounded loop over `DictInfo`
- `DictInfo` entry:
  - `registryId` + width-switch `moduleIndex`
  - UTF string via `StringIO.readUTF` / `StringIO.writeUTF`
  - bitmap-controlled optional/variable fields:
    - optional `modId` (`flags & 0x01`)
    - optional `raw_num_mod_overrides` (`flags & 0x10` and not `flags & 0x20`)
    - `modOverrides` array (`flags & 0x10`) with derived count

## Header extraction
- `numModIds`: `int32` (big-endian)
- `numModules`: `int32` (big-endian)
- `numEntries`: `int32` (big-endian)

## DictInfo field order (micro)
1. `registryId`: `int16`
2. `moduleIndex`:
   - `uint16` semantic value when `numModules > 127` (`getShort` + unsigned conversion)
   - `uint8` semantic value otherwise (`get` + unsigned conversion)
3. `name`: length-prefixed UTF-8 string (`u2 len` + bytes)
4. `flags`: `u1` bitmap
5. `modId` (present if `flags & 0x01`):
   - `uint16` semantic value when `numModIds > 127`
   - `uint8` semantic value otherwise
6. `raw_num_mod_overrides` (present if `flags & 0x10` and `(flags & 0x20) == 0`): `u1`
7. `modOverrides` (present if `flags & 0x10`): repeated mod id values with width selected by `numModIds > 127`

## Derived conditions and counts
- `flags & 0x01`: explicit `modId` field exists.
- `flags & 0x10`: override section is enabled.
- `flags & 0x20`: override count is implicit `1` (single override mode).
- `numOverrides` derivation in load path:
  - if `flags & 0x10` and not `flags & 0x20`: read `u1`
  - else if `flags & 0x20`: use `1`
  - else: use `0`

## String helper extraction
- `StringIO.writeUTF`: writes `u2` byte length, then raw UTF-8 bytes.
- `StringIO.readUTF`: reads `u2` byte length, then exact byte count and decodes UTF-8.

## Micro extraction notes
- Endian: big-endian (`ByteBuffer` default).
- Java load path normalizes variable-width numeric fields to unsigned semantics.
- Save/load asymmetry detail: when `flags & 0x20` is set without `flags & 0x01`, save uses `modId` as source for the single override value; schema mirrors actual stream shape, not higher-level semantic intent.


