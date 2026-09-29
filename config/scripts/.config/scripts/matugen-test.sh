#!/bin/sh

# Set the path to your wallpaper file. This should be passed to the script.
WALLPAPER_PATH=$1

# Exit if no wallpaper path is provided
if [ -z "$WALLPAPER_PATH" ]; then
    echo "Error: No wallpaper path provided."
    exit 1
fi

# --- Step 1: Generate colors with matugen ---
echo "Generating colors with matugen..."

# Generate Hyprland colors
matugen -s material -g hyprland -i "$WALLPAPER_PATH" > ~/.config/hypr/hyprland_colors.conf

# Generate Kitty colors
matugen -s material -g kitty -i "$WALLPAPER_PATH" > ~/.config/kitty/kitty_colors.conf

# --- Step 2: Reload configurations ---

echo "Reloading configurations..."

# Reload Hyprland. We source the generated file in the main hyprland.conf.
# This assumes your hyprland.conf has a line like:
# source = ~/.config/hypr/hyprland_colors.conf
hyprctl dispatch reload

# Inform Kitty to reload colors for all open windows
kitty @ set-colors --all ~/.config/kitty/kitty_colors.conf

echo "Color change complete!"
