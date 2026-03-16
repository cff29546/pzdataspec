# custom_process_length_calc_analysis

## Entry points
- `gen_row()` in `input/gen_test.py` writes `<u8 flags>` then `popcount(flags)` values.
- custom process class `BitCount.decode(...)` in `output/bit_count.py`.

## Core pattern
- Read raw flags bytes.
- Run custom Python `process: bit_count` to convert flags to `num_values`.
- Use processed result as `repeat-expr` for following array.

## Why this is a good skill example
- Demonstrates target-language custom process integration.
- Demonstrates non-trivial length derivation that is not directly present as a serialized field.
