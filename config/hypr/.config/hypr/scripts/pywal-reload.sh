#!/usr/bin/env bash
# pywal-reload.sh — push the palette currently in ~/.cache/wal to running apps.
#
# Usage: pywal-reload.sh [--startup]
#
# Called by wallpapers.sh after `wal -n -e -i <image>`. The -e makes wal skip
# its own reload hooks (pywal16 would otherwise SIGUSR2 waybar and run pywalfox
# itself, on top of what this script does). Everything here therefore happens
# exactly once, and nothing here sends a notification or reloads Hyprland's
# config on an ordinary wallpaper change.
#
# --startup: also run `hyprctl reload`. Only wanted at login, where it clears
# the "source file missing" warning a fresh machine gets before the first wal
# run. Never used for interactive changes: a config reload re-applies rules,
# re-sets the keyboard layout and re-animates layers, which is disruptive to
# anything open at the time (e.g. rofi).
#
# What consumes which generated file:
#   Hyprland  hyprland.conf  source = ~/.cache/wal/colors-hypr.conf   (user template)
#   hyprlock  hyprlock.conf  source = ~/.cache/wal/hyprlock-colors.conf (user template)
#   waybar    style.css      @import ~/.cache/wal/colors-waybar.css     (pywal built-in)
#   swaync    style.css      @import ~/.cache/wal/colors-waybar.css     (pywal built-in)
#   kitty     kitty.conf     include ~/.cache/wal/colors-kitty.conf     (pywal built-in)
#   rofi      menu.rasi      @import ~/.cache/wal/colors-rofi-dark.rasi (pywal built-in;
#                            rofi reads it on launch, nothing to reload)

# --- toggles: set to 0 to skip a step -------------------------------------
RELOAD_HYPRLAND=1   # border colours via hyprctl keyword
RELOAD_WAYBAR=1     # SIGUSR2 = waybar restarts its bars once (only way to re-read CSS)
RELOAD_SWAYNC=1     # swaync-client --reload-css
RELOAD_KITTY=1      # kitty @ set-colors on every kitty socket
RELOAD_XRDB=1       # xrdb -merge for XWayland apps
RELOAD_PYWALFOX=0   # pywalfox update (Firefox theme)
# --------------------------------------------------------------------------

WAL_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/wal"
HYPR_COLORS="$WAL_CACHE/colors-hypr.conf"
STARTUP=0
[ "${1:-}" = "--startup" ] && STARTUP=1

if [ ! -f "$WAL_CACHE/colors.sh" ]; then
    echo "pywal-reload: $WAL_CACHE/colors.sh not found; run 'wal -i <image>' first" >&2
    exit 1
fi

have()    { command -v "$1" >/dev/null 2>&1; }
running() { pgrep -x "$1"  >/dev/null 2>&1; }

# Value of a `$name = value` line in the generated Hyprland colour file.
hypr_var() { sed -n 's/^\$'"$1"'[[:space:]]*=[[:space:]]*//p' "$HYPR_COLORS" | head -n 1; }

# --- Hyprland -------------------------------------------------------------
if [ "$RELOAD_HYPRLAND" = 1 ] && have hyprctl && [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
    if [ "$STARTUP" = 1 ]; then
        hyprctl reload >/dev/null 2>&1
    elif [ -f "$HYPR_COLORS" ]; then
        active=$(hypr_var active_border)
        inactive=$(hypr_var inactive_border)
        if [ -n "$active" ] && [ -n "$inactive" ]; then
            hyprctl --batch \
                "keyword general:col.active_border $active ; keyword general:col.inactive_border $inactive" \
                >/dev/null 2>&1
        fi
    fi
fi

# --- Waybar ---------------------------------------------------------------
if [ "$RELOAD_WAYBAR" = 1 ] && running waybar; then
    pkill -SIGUSR2 -x waybar
fi

# --- swaync ---------------------------------------------------------------
if [ "$RELOAD_SWAYNC" = 1 ] && running swaync && have swaync-client; then
    swaync-client --reload-css >/dev/null 2>&1
fi

# --- Kitty ----------------------------------------------------------------
# wal already wrote OSC colour sequences to every open pty, and kitty.conf
# includes colors-kitty.conf for new windows. This covers windows whose pty wal
# could not reach. kitty appends its PID to the listen_on path: glob for them.
if [ "$RELOAD_KITTY" = 1 ] && have kitty; then
    for sock in /tmp/kitty-socket*; do
        [ -S "$sock" ] || continue
        kitty @ --to "unix:$sock" set-colors -a -c "$WAL_CACHE/colors-kitty.conf" >/dev/null 2>&1
    done
fi

# --- Xresources (XWayland apps) ------------------------------------------
if [ "$RELOAD_XRDB" = 1 ] && have xrdb && [ -f "$WAL_CACHE/colors.Xresources" ]; then
    xrdb -merge -quiet "$WAL_CACHE/colors.Xresources" 2>/dev/null
fi

# --- Firefox via pywalfox -------------------------------------------------
if [ "$RELOAD_PYWALFOX" = 1 ] && have pywalfox; then
    pywalfox update >/dev/null 2>&1
fi

exit 0
