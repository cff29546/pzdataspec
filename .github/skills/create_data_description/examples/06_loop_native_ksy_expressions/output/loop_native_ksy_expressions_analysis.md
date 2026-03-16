# loop_native_ksy_expressions_analysis

## Entry points
- `gen_binary(size)` in `input/gen_test.py` creates byte stream.

## Core pattern
- Parser splits stream into fixed-width segment and tail segment.
- Per-byte bit count (`mask_u1.bits`) is reduced using array-loop expression:
  - `prefix_sum[_index - 1]` accumulation pattern.
- Final count is exposed as `total_bits` instance.

## Why this is a good skill example
- Demonstrates loop logic in native `.ksy` expressions without target-language helpers.
- Demonstrates reducer-style expression over parsed array elements.
