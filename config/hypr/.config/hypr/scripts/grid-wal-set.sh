#!/usr/bin/env bash
# wal-set.sh — rofi wallpaper picker with thumbnails (bound to alt+W in hyprland.conf).
#
#   Enter    apply the highlighted wallpaper
#   Ctrl+R   random wallpaper
#   Esc      close
#
# Thumbnails are generated once per wallpaper into $THUMB_DIR with ImageMagick
# (which pywal already needs) and reused. Handing rofi the full-size images
# would make it rescale every one on every launch.

WALLPAPER_DIR="${WALLPAPER_DIR:-$HOME/.local/share/wallpapers}"
WALLPAPERS_SCRIPT="$HOME/.config/hypr/scripts/wallpapers.sh"
THEME="$HOME/.config/rofi/wallpaper.rasi"
THUMB_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/wallpaper-thumbs"
THUMB_PX=400          # square, centre-cropped; rofi scales it down to element-icon size
STATE_LAST="${XDG_STATE_HOME:-$HOME/.local/state}/wallpapers/last"

if [ ! -x "$WALLPAPERS_SCRIPT" ]; then
    echo "wal-set: $WALLPAPERS_SCRIPT missing or not executable" >&2
    exit 1
fi
mkdir -p "$THUMB_DIR"

# --- collect wallpapers ----------------------------------------------------
mapfile -d '' -t paths < <(
    find "$WALLPAPER_DIR" -type f \
        \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.gif' -o -iname '*.webp' \) \
        -print0 | sort -zV
)
if [ "${#paths[@]}" -eq 0 ]; then
    echo "wal-set: no wallpapers in $WALLPAPER_DIR" >&2
    exit 1
fi

thumb_for() { printf '%s/%s.jpg' "$THUMB_DIR" "$(printf '%s' "$1" | md5sum | cut -c1-32)"; }

# --- thumbnails: build missing/stale ones in parallel ---------------------
if command -v magick >/dev/null 2>&1; then IM=magick; else IM=convert; fi
export IM THUMB_PX
make_thumb() {   # <source> <thumbnail>
    "$IM" "${1}[0]" -auto-orient \
        -thumbnail "${THUMB_PX}x${THUMB_PX}^" -gravity center -extent "${THUMB_PX}x${THUMB_PX}" \
        -quality 85 "$2" 2>/dev/null
}
export -f make_thumb

thumbs=()
todo=()
for p in "${paths[@]}"; do
    t=$(thumb_for "$p")
    thumbs+=("$t")
    if [ ! -f "$t" ] || [ "$p" -nt "$t" ]; then
        todo+=("$p" "$t")
    fi
done
if [ "${#todo[@]}" -gt 0 ]; then
    printf '%s\0' "${todo[@]}" | xargs -0 -n 2 -P "$(nproc)" bash -c 'make_thumb "$0" "$1"'
fi

# Prune thumbnails whose wallpaper no longer exists.
declare -A keep=()
for t in "${thumbs[@]}"; do keep["$t"]=1; done
for t in "$THUMB_DIR"/*.jpg; do
    [ -e "$t" ] && [ -z "${keep[$t]:-}" ] && rm -f -- "$t"
done

# --- current wallpaper: preselect it and mark it "active" -----------------
current=$(head -n 1 -- "$STATE_LAST" 2>/dev/null)
sel=0
for i in "${!paths[@]}"; do
    if [ "${paths[i]}" = "$current" ]; then
        sel=$i
        break
    fi
done

# --- rofi ------------------------------------------------------------------
# One entry per line: "<label>\0icon\x1f<thumbnail>". -format i makes rofi
# print the index of the chosen row, so odd filenames never matter.
choice=$(
    for i in "${!paths[@]}"; do
        label="${paths[i]#"$WALLPAPER_DIR/"}"
        printf '%s\0icon\x1f%s\n' "${label%.*}" "${thumbs[i]}"
    done | rofi -dmenu -i -show-icons \
        -theme "$THEME" \
        -p "Wallpaper" \
        -mesg "Enter: apply    Ctrl+R: random    Esc: close" \
        -format i \
        -selected-row "$sel" -a "$sel" \
        -kb-custom-1 "Control+r"
)
rc=$?

case $rc in
    0)
        # -1 = Enter on a filter that matched nothing.
        [ "$choice" -ge 0 ] 2>/dev/null || exit 0
        exec "$WALLPAPERS_SCRIPT" set "${paths[choice]}"
        ;;
    10) exec "$WALLPAPERS_SCRIPT" random ;;      # kb-custom-1
    *)  exit 0 ;;                                 # Esc
esac
