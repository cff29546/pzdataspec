meta:
  id: remaining_stream_conditional_typing
  endian: be
doc: |
  Example where optional type is decided by remaining stream length.

seq:
  - id: head
    type: u1
  - id: optional
    type: optional_u1(0)
    size-eos: true

types:
  optional_u1:
    params:
      - id: default_value
        type: u1
    seq:
      - id: data
        type: byte_tail
        size-eos: true
    instances:
      raw_value:
        io: data._io
        pos: 0
        type: u1
        if: data.size > 0
      value:
        value: '(data.size > 0) ? raw_value : default_value'

  byte_tail:
    seq:
      - id: data
        type: u1
        repeat: eos
    instances:
      size:
        value: data.size
