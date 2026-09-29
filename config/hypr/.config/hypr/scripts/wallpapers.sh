#!/usr/bin/env bash
# wallpapers.sh — set the wallpaper with swww, regenerate the pywal palette,
# then push it to running applications via pywal-reload.sh.
#
# Usage: wallpapers.sh set <path> | random | next | prev | startup
#
# Pipeline (every mode):
#   1. resolve an image path
#   2. wait for swww-daemon (start it if absent) and set the wallpaper
#   3. record it as the last wallpaper
#   4. wal -n -e -i <image> -> regenerates ~/.cache/wal/*, including the user
#      templates in ~/.config/wal/templates (colors-hypr.conf, hyprlock-colors.conf),
#      and pushes colours to open terminals. -e stops wal running its own
#      app-reload hooks so step 5 is the only place anything gets reloaded.
#   5. pywal-reload.sh      -> Hyprland borders, waybar, swaync, kitty, ... once each
#
# "startup" is run from hyprland.conf as exec-once. Hyprland launches exec-once
# entries concurrently, so this script must not assume swww-daemon is ready.

set -o pipefail

WALLPAPER_DIR="${WALLPAPER_DIR:-$HOME/.local/share/wallpapers}"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/wallpapers"
LAST_FILE="$STATE_DIR/last"
LEGACY_LAST_FILE="$HOME/.config/hypr/last_wallpaper.txt"   # old location, read-only fallback
LOG_FILE="$STATE_DIR/wallpapers.log"
RELOAD_SCRIPT="$HOME/.config/hypr/scripts/pywal-reload.sh"

SWWW_ARGS=(
    --transition-type grow
    --transition-pos top-right
    --transition-duration 0.8
    --transition-fps 144
)
SWWW_WAIT_SECS=10

mkdir -p "$STATE_DIR"

# Under Hyprland there is no tty: keep a log so startup problems can be inspected.
if [ ! -t 2 ]; then
    exec >>"$LOG_FILE" 2>&1
fi

log() { printf '[%(%F %T)T] %s\n' -1 "$*"; }
die() { log "ERROR: $*"; exit 1; }

# NUL-separated, version-sorted list of image files.
list_wallpapers() {
    find "$WALLPAPER_DIR" -type f \
        \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.gif' -o -iname '*.webp' \) \
        -print0 | sort -zV
}

random_wallpaper() {
    list_wallpapers | shuf -zn 1 | tr -d '\0'
}

# Print the last wallpaper path, or return 1 if none is recorded.
last_wallpaper() {
    local f
    for f in "$LAST_FILE" "$LEGACY_LAST_FILE"; do
        if [ -s "$f" ]; then
            head -n 1 -- "$f"
            return 0
        fi
    done
    return 1
}

# Ensure swww-daemon is running and accepting connections.
wait_for_swww() {
    command -v swww >/dev/null 2>&1 || die "swww is not installed"
    if ! pgrep -x swww-daemon >/dev/null 2>&1; then
        log "swww-daemon not running; starting it"
        swww-daemon >/dev/null 2>&1 &
        disown
    fi
    local i
    for ((i = 0; i < SWWW_WAIT_SECS * 10; i++)); do
        if swww query >/dev/null 2>&1; then
            return 0
        fi
        sleep 0.1
    done
    return 1
}

# ---------------------------------------------------------------------------
# 1. Resolve the image
# ---------------------------------------------------------------------------
case "${1:-}" in
    set)
        IMAGE="${2:-}"
        [ -n "$IMAGE" ] && [ -f "$IMAGE" ] || die "set: not a file: '$IMAGE'"
        IMAGE=$(realpath -- "$IMAGE")
        ;;
    random)
        IMAGE=$(random_wallpaper)
        ;;
    next|prev)
        mapfile -d '' -t WALLPAPERS < <(list_wallpapers)
        n=${#WALLPAPERS[@]}
        [ "$n" -gt 0 ] || die "no wallpapers found in $WALLPAPER_DIR"

        current=$(last_wallpaper || true)
        idx=-1
        for i in "${!WALLPAPERS[@]}"; do
            if [ "${WALLPAPERS[i]}" = "$current" ]; then
                idx=$i
                break
            fi
        done

        if [ "$idx" -lt 0 ]; then
            # Current wallpaper not in the list: start from an end.
            if [ "$1" = next ]; then idx=0; else idx=$((n - 1)); fi
        elif [ "$1" = next ]; then
            idx=$(( (idx + 1) % n ))
        else
            idx=$(( (idx - 1 + n) % n ))
        fi
        IMAGE="${WALLPAPERS[idx]}"
        ;;
    startup)
        IMAGE=$(last_wallpaper || true)
        if [ -z "$IMAGE" ] || [ ! -f "$IMAGE" ]; then
            log "no usable last wallpaper ('${IMAGE:-none}'); choosing a random one"
            IMAGE=$(random_wallpaper)
        fi
        ;;
    *)
        echo "usage: ${0##*/} {set <path> | random | next | prev | startup}" >&2
        exit 2
        ;;
esac

[ -n "$IMAGE" ] && [ -f "$IMAGE" ] || die "no valid wallpaper resolved ('${IMAGE:-empty}')"

# ---------------------------------------------------------------------------
# 2. Wallpaper
# ---------------------------------------------------------------------------
wait_for_swww || die "swww-daemon did not become ready within ${SWWW_WAIT_SECS}s"

log "setting wallpaper: $IMAGE"
swww img "$IMAGE" "${SWWW_ARGS[@]}" || die "swww img failed"

# ---------------------------------------------------------------------------
# 3. State
# ---------------------------------------------------------------------------
printf '%s\n' "$IMAGE" >"$LAST_FILE"

# ---------------------------------------------------------------------------
# 4. Palette
# ---------------------------------------------------------------------------
if ! command -v wal >/dev/null 2>&1; then
    log "wal is not installed; wallpaper set, skipping theme generation"
    exit 0
fi

log "generating pywal palette"
# -n: do not set the wallpaper (swww already did).
# -e: do not run wal's own reload hooks (xrdb/kitty/waybar/pywalfox/...);
#     pywal-reload.sh does each of those exactly once instead.
# wal still regenerates every template and pushes colours to open terminals.
wal -n -e -s -i "$IMAGE" || die "wal failed"

# ---------------------------------------------------------------------------
# 5. Apply to running applications
# ---------------------------------------------------------------------------
# --startup additionally does a full `hyprctl reload` (clears the first-boot
# "source file missing" warning). Interactive changes never reload the config.
RELOAD_ARGS=()
[ "$1" = startup ] && RELOAD_ARGS=(--startup)

if [ -x "$RELOAD_SCRIPT" ]; then
    "$RELOAD_SCRIPT" "${RELOAD_ARGS[@]}" || log "warning: $RELOAD_SCRIPT exited non-zero"
else
    log "warning: $RELOAD_SCRIPT missing or not executable; applications not reloaded"
fi

log "done"
exit 0
