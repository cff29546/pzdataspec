meta:
  id: loop_native_ksy_expressions
  endian: be
doc: |
  Example of loop/reduction over arrays using native KSY expression language.

seq:
  - id: head
    type: u1
  - id: fixed_mask
    type: bit_mask(4)
  - id: tail_mask
    type: bit_mask_eos

instances:
  total_bits:
    value: fixed_mask.bits + tail_mask.bits

types:
  bit_mask:
    params:
      - id: len_data
        type: u4
    seq:
      - id: data
        type: bit_mask_eos
        size: len_data
    instances:
      bits:
        value: data.bits

  bit_mask_eos:
    seq:
      - id: data
        type: mask_u1
        repeat: eos
    instances:
      prefix_sum:
        type: 'reduce_sum(data[_index].bits, (_index == 0) ? 0 : prefix_sum[_index - 1].result)'
        repeat: expr
        repeat-expr: data.size
      bits:
        value: '(data.size == 0) ? 0 : prefix_sum.last.result'

  reduce_sum:
    params:
      - id: a
        type: u4
      - id: b
        type: u4
    instances:
      result:
        value: a + b

  mask_u1:
    seq:
      - id: raw
        type: u1
    instances:
      s2:
        value: (raw & 0x55) + ((raw >> 1) & 0x55)
      s4:
        value: (s2 & 0x33) + ((s2 >> 2) & 0x33)
      bits:
        value: (s4 & 0x0F) + ((s4 >> 4) & 0x0F)
