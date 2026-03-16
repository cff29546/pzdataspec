meta:
  id: custom_process_length_calc
  endian: le
doc: |
  Example of custom-processing a raw flags field to derive repeat length.

seq:
  - id: blocks
    type: block
    repeat: expr
    repeat-expr: 8

types:
  block:
    seq:
      - id: flags_processed
        size: 8
        type: processed_bit_count
      - id: values
        type: u4
        repeat: expr
        repeat-expr: flags_processed.bit_count.value
    instances:
      flags:
        value: flags_processed.flags
      num_values:
        value: flags_processed.bit_count.value

  processed_bit_count:
    seq:
      - id: bit_count
        size: 8
        process: bit_count
        type: bit_count
    instances:
      flags:
        pos: 0
        type: u8

  bit_count:
    seq:
      - id: value
        type: u8
