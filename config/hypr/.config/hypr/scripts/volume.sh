#!/usr/bin/env bash

SINK=@DEFAULT_AUDIO_SINK@

case "$1" in
  up)
    wpctl set-mute "$SINK" 0
    wpctl set-volume -l 1.0 "$SINK" 5%+
    ;;
  down)
    wpctl set-volume "$SINK" 5%-
    ;;
  mute)
    wpctl set-mute "$SINK" toggle
    ;;
  *)
    echo "Usage: volume.sh {up|down|mute}"
    ;;
esac
