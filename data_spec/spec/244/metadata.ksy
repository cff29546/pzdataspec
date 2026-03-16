meta:
  id: metadata
  endian: be
  imports:
    - ../common/common
seq:
  # zombie.iso.MetaTracker.save / load
  - id: world_version
    type: u4
  - id: helicopter
    type: helicopter
  - id: ambient
    type: optional_ambient
    size-eos: true
types:
  # zombie.iso.Helicopter.load
  helicopter:
    seq:
      - id: active
        type: u1
      - id: state_id
        type: u4
      - id: x
        type: f4
      - id: y
        type: f4
    instances:
      state:
        value: '(state_id == 0) ? "Arriving" :
                (state_id == 1) ? "Hovering" :
                (state_id == 2) ? "Searching" :
                (state_id == 3) ? "Leaving" :
                "Unknown"'

  optional_ambient:
    seq:
      - id: data
        type: common::bytes_eos
        size-eos: true
    instances:
      ambient:
        io: data._io
        pos: 0
        type: ambient
        if: data.size > 0

  # zombie.AmbientStreamManager.load (this needs Core.soundDisabled == false)
  ambient:
    seq:
      - id: num_alarms
        type: u2
      - id: alarms
        type: ambient_alarm
        repeat: expr
        repeat-expr: num_alarms

  # zombie.iso.Alarm.load
  ambient_alarm:
    seq:
      - id: x
        type: s4
      - id: y
        type: s4
      - id: end_game_time
        type: f4 
