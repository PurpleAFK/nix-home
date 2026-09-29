#!/bin/bash

# This script creates a calendar popup using yad.
# It attempts to position the popup near the clicked Waybar clock.

# Get Waybar properties (replace 'clock' with your actual clock module ID if different)
# The actual position of the popup can be tricky with Wayland and GTK apps.
# This tries to get the Waybar window ID and position, but yad might not
# perfectly align with it on all setups.

# You might need to adjust the position manually.
# If using Hyprland, you can set rules for yad windows in hyprland.conf
# for_window [title="yad-calendar"] float, noborder, sticky, move exact X Y

# Get current date for pre-selection (optional)
CURRENT_DATE=$(date +%d/%m/%Y)

# Launch yad calendar
# --undecorated: Removes window decorations (title bar, close buttons)
# --fixed: Prevents resizing
# --close-on-unfocus: Closes the dialog when it loses focus (good for popups)
# --no-buttons: Removes OK/Cancel buttons
# --title="yad-calendar": Sets a window title, useful for Hyprland rules
# --posx/--posy: Attempts to position the window.
#                Calculating exact Waybar clock position for perfect alignment is complex.
#                You may need to manually fine-tune these values based on your screen resolution
#                and Waybar position.
#                A common trick is to position it relative to the cursor (if xdotool/wlrctl available,
#                but wlrctl is still experimental/limited for this on Wayland).
#                For simplicity, let's start with a fixed position or center it.

# Option 1: Basic calendar, let WM position
# yad --calendar --undecorated --fixed --close-on-unfocus --no-buttons --title="yad-calendar"

# Option 2: Attempt to position (adjust posx/posy as needed for your screen)
# These values are examples.
# If Waybar is top-left, you might start with posx=10, posy=50
# If Waybar is top-center, you'll need to calculate screen width / 2 - (yad_width / 2)
# A common approach for exact positioning is to use a tool like 'wlrctl cursor pos'
# but that often requires manual calculation or a more complex script.

# For now, let's use a simpler approach that lets Yad position it, then Hyprland rule.
# Or, if you want it exactly centered, you can use --center.

yad_command="yad --calendar --undecorated --fixed --close-on-unfocus --no-buttons --title=\"yad-calendar\""

# You can customize the date format returned if you wanted to do something with the selection
# yad --calendar --date-format="%Y-%m-%d"

# Execute the yad command
eval "$yad_command"

exit 0
