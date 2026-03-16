meta:
  id: polygon
  endian: be
types:
  polygon:
    seq:
      - id: raw
        size-eos: true
        valid:
          expr: _.size >= 8
    doc: |
      Mock type for `Polygon` structure, which is still unresolved.