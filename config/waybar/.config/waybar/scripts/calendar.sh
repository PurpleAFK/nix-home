#!/usr/bin/env bash
# Toggle a clickable month calendar (clock on-click in waybar).
# Double-clicking a day copies it as dd/mm/yy and closes the calendar.
# Window placement lives in hyprland.conf (windowrule on title yad-calendar).

if pkill -f '^yad --calendar'; then
  exit 0
fi

out=$(mktemp)
trap 'rm -f "$out"; pkill -P $$ 2>/dev/null' EXIT

# yad prints the date and exits 0 on a double-click; Esc / being killed exits non-zero.
yad --calendar --title=yad-calendar --no-buttons \
  --css="$HOME/.cache/wal/colors-yad.css" \
  --skip-taskbar --show-weeks --width=320 \
  --date-format=%d/%m/%y >"$out" &
pid=$!

# Close when another window takes focus. (yad's --close-on-unfocus fires
# before Hyprland ever focuses it, so watch Hyprland's event socket instead.)
sock="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
(
  focused=0
  socat -U - UNIX-CONNECT:"$sock" | while read -r line; do
    kill -0 "$pid" 2>/dev/null || break
    case "$line" in
      activewindow\>\>*,yad-calendar) focused=1 ;;
      activewindow\>\>*) (( focused )) && kill "$pid" 2>/dev/null && break ;;
    esac
  done
) &

if wait "$pid" && [ -s "$out" ]; then
  wl-copy -n < "$out"
fi
