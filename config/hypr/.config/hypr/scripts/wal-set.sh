#!/usr/bin/env bash
# wal-set.sh — rofi front-end for wallpapers.sh (bound to alt+W in hyprland.conf).

WALLPAPER_DIR="${WALLPAPER_DIR:-$HOME/.local/share/wallpapers}"
WALLPAPERS_SCRIPT="$HOME/.config/hypr/scripts/wallpapers.sh"

if [ ! -x "$WALLPAPERS_SCRIPT" ]; then
    echo "wal-set: $WALLPAPERS_SCRIPT missing or not executable" >&2
    exit 1
fi

# Filenames relative to WALLPAPER_DIR, version-sorted.
mapfile -t files < <(
    find "$WALLPAPER_DIR" -type f \
        \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.gif' -o -iname '*.webp' \) \
        -printf '%P\n' | sort -V
)

selected=$(printf '%s\n' "Random" "Next" "Previous" "${files[@]}" | rofi -dmenu -i -p "Wallpaper:")

case "$selected" in
    "")         exit 0 ;;                                   # cancelled
    Random)     exec "$WALLPAPERS_SCRIPT" random ;;
    Next)       exec "$WALLPAPERS_SCRIPT" next ;;
    Previous)   exec "$WALLPAPERS_SCRIPT" prev ;;
    *)
        path="$WALLPAPER_DIR/$selected"
        if [ -f "$path" ]; then
            exec "$WALLPAPERS_SCRIPT" set "$path"
        fi
        echo "wal-set: not a file: '$path'" >&2
        exit 1
        ;;
esac
