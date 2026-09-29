#!/bin/bash

# Configuration
# The ID is used to replace the same notification with a new one
APP_NAME="$(hostname)"
ID=1847

function get_volume {
  pactl list sinks | grep 'Volume: front-left' | awk '{print $5}' | sed 's/%//g'
}

function is_muted {
  pactl list sinks | grep 'Mute: yes' &> /dev/null
}

function send_notification {
  volume=$(get_volume)

  # You can customize these icons and the notification text
  # Make sure you have the icons in the specified directory or a valid path
  if is_muted ; then
    icon_name="/usr/share/icons/breeze-dark/status/24/audio-volume-muted.svg"
    notify-send -a "$APP_NAME" -i "$icon_name" -r "$ID" "Volume muted" -t 1500 -h int:value:$volume
  else
    if [ "$volume" -gt 70 ]; then
      icon_name="/usr/share/icons/breeze-dark/status/24/audio-volume-high.svg"
    elif [ "$volume" -gt 30 ]; then
      icon_name="/usr/share/icons/breeze-dark/status/24/audio-volume-medium.svg"
    else
      icon_name="/usr/share/icons/breeze-dark/status/24/audio-volume-low.svg"
    fi
    notify-send -a "$APP_NAME" -i "$icon_name" -r "$ID" "Volume: $volume%" -t 1500 -h int:value:$volume
  fi
}

case "$1" in
  up)
    if is_muted; then
      pactl set-sink-mute @DEFAULT_SINK@ 0
    fi
    pactl set-sink-volume @DEFAULT_SINK@ +5%
    send_notification
    ;;
  down)
    if is_muted; then
      send_notification
      exit
    fi
    pactl set-sink-volume @DEFAULT_SINK@ -5%
    send_notification
    ;;
  mute)
    pactl set-sink-mute @DEFAULT_SINK@ toggle
    send_notification
    ;;
  *)
    echo "Usage: volume.sh {up|down|mute}"
    ;;
esac
