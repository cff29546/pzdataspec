meta:
  id: cls_9_radio
  endian: be

types:
  radio:
    seq:
      - id: len_channel
        type: u2
      - id: channel
        type: str
        size: len_channel
        encoding: UTF-8
