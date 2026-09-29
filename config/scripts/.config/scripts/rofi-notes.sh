# !/bin/bash
#
# # --- Configure your preferred terminal emulator here ---
# TERMINAL_EMULATOR="kitty" # <--- CHANGE THIS to your preferred terminal!
#
# NOTES_DIR="$HOME/Documents/Notes"
# # Ensure the notes directory exists
# mkdir -p "$NOTES_DIR"
#
# # Define the "Delete Note" option that will appear in Rofi
# DELETE_OPTION=" [Delete Note]"
#
# # Get list of existing notes
# # -maxdepth 1 to only get files directly in the directory, not subdirectories
# EXISTING_NOTES=$(find "$NOTES_DIR" -maxdepth 1 -type f -print0 | xargs -0 -n 1 basename | sort)
#
# # Prepend the delete option to the list of existing notes
# # This ensures it always appears at the top (or near the top depending on sort order,
# # but square brackets usually sort before letters)
# ALL_CHOICES_LIST="${DELETE_OPTION}\n${EXISTING_NOTES}"
#
# # Rofi prompt for existing notes, creating a new one, or selecting delete option
# SELECTED_ACTION=$(echo -e "$ALL_CHOICES_LIST" | rofi -dmenu -i -p "Notes" -theme ~/.config/rofi/config.rasi)
#
# # If no choice was made (Rofi was closed), exit
# if [ -z "$SELECTED_ACTION" ]; then
#     exit 0
# fi
#
# # --- Main Logic Branching ---
#
# # If the "Delete Note" option was chosen
# if [ "$SELECTED_ACTION" = "$DELETE_OPTION" ]; then
#     # --- Delete Note Workflow ---
#     NOTE_TO_DELETE=$(find "$NOTES_DIR" -maxdepth 1 -type f -print0 | xargs -0 -n 1 basename | sort | rofi -dmenu -i -p "DELETE: Select note to remove" -theme ~/.config/rofi/config.rasi)
#
#     # If no note was selected for deletion (second Rofi was closed), exit
#     if [ -z "$NOTE_TO_DELETE" ]; then
#         echo "No note selected for deletion. Operation cancelled."
#         exit 0
#     fi
#
#     # Confirmation step
#     # Default to "No" for safety (-selected-row 0)
#     CONFIRMATION=$(echo -e "No\nYes" | rofi -dmenu -i -p "Are you sure you want to delete '$NOTE_TO_DELETE'?" -selected-row 0 -theme ~/.config/rofi/config.rasi)
#
#     if [ "$CONFIRMATION" = "Yes" ]; then
#         if [ -f "$NOTES_DIR/$NOTE_TO_DELETE" ]; then
#             rm "$NOTES_DIR/$NOTE_TO_DELETE"
#             echo "Note '$NOTE_TO_DELETE' deleted successfully."
#             # Optional: Display a temporary notification
#             notify-send "Notes App" "Note '$NOTE_TO_DELETE' deleted successfully."
#         else
#             echo "Error: Note '$NOTE_TO_DELETE' not found in '$NOTES_DIR'."
#             notify-send "Notes App Error" "Note '$NOTE_TO_DELETE' not found."
#         fi
#     else
#         echo "Deletion of '$NOTE_TO_DELETE' cancelled."
#         notify-send "Notes App" "Deletion cancelled for '$NOTE_TO_DELETE'."
#     fi
#
# else
#     # --- Open/Create Note Workflow (as before) ---
#     # Check if the chosen action corresponds to an existing note file
#     if [ -f "$NOTES_DIR/$SELECTED_ACTION" ]; then
#         # Open existing note in terminal with nvim
#         "$TERMINAL_EMULATOR" -e nvim "$NOTES_DIR/$SELECTED_ACTION"
#     else
#         # If not an existing file, treat it as a new note name
#         NEW_NOTE_NAME=$(echo "$SELECTED_ACTION" | tr ' ' '_') # Replace spaces with underscores
#         
#         if [ -z "$NEW_NOTE_NAME" ]; then
#             echo "No note name provided. Exiting."
#             exit 1
#         fi
#
#         # Create and open new note in terminal with nvim
#         # Using .md extension for Markdown by default
#         touch "$NOTES_DIR/$NEW_NOTE_NAME.md" 
#         "$TERMINAL_EMULATOR" -e nvim "$NOTES_DIR/$NEW_NOTE_NAME.md"
#     fi
# fi



#!/bin/bash

# --- Configure your preferred terminal emulator here ---
TERMINAL_EMULATOR="kitty" 

NOTES_DIR="$HOME/Documents/Notes"
mkdir -p "$NOTES_DIR"

# --- Rofi Appearance Settings (Change these to resize the box) ---
# Width can be pixels (e.g., 800px) or percentage (50%)
ROFI_STYLE='window { width: 40%; } listview { lines: 12; }'

DELETE_OPTION=" [Delete Note]"

# Get list of existing notes
EXISTING_NOTES=$(find "$NOTES_DIR" -maxdepth 1 -type f -print0 | xargs -0 -n 1 basename | sort)
ALL_CHOICES_LIST="${DELETE_OPTION}\n${EXISTING_NOTES}"

# Main Rofi window
SELECTED_ACTION=$(echo -e "$ALL_CHOICES_LIST" | rofi -dmenu -i -p "Notes" \
    -theme-str "$ROFI_STYLE" \
    -theme ~/.config/rofi/config.rasi)

if [ -z "$SELECTED_ACTION" ]; then
    exit 0
fi

if [ "$SELECTED_ACTION" = "$DELETE_OPTION" ]; then
    # --- Delete Note Workflow ---
    NOTE_TO_DELETE=$(find "$NOTES_DIR" -maxdepth 1 -type f -print0 | xargs -0 -n 1 basename | sort | \
        rofi -dmenu -i -p "DELETE: " \
        -theme-str "$ROFI_STYLE" \
        -theme ~/.config/rofi/config.rasi)

    if [ -z "$NOTE_TO_DELETE" ]; then
        exit 0
    fi

    # Confirmation step (Using a smaller box for confirmation)
    CONFIRMATION=$(echo -e "No\nYes" | rofi -dmenu -i -p "Delete '$NOTE_TO_DELETE'?" \
        -selected-row 0 \
        -theme-str 'window { width: 25%; } listview { lines: 2; }' \
        -theme ~/.config/rofi/config.rasi)

    if [ "$CONFIRMATION" = "Yes" ]; then
        if [ -f "$NOTES_DIR/$NOTE_TO_DELETE" ]; then
            rm "$NOTES_DIR/$NOTE_TO_DELETE"
            notify-send "Notes App" "Note '$NOTE_TO_DELETE' deleted successfully."
        fi
    fi

else
    # --- Open/Create Note Workflow ---
    if [ -f "$NOTES_DIR/$SELECTED_ACTION" ]; then
        "$TERMINAL_EMULATOR" -e nvim "$NOTES_DIR/$SELECTED_ACTION"
    else
        # Replace spaces with underscores and ensure .md extension
        NEW_NOTE_NAME=$(echo "$SELECTED_ACTION" | tr ' ' '_')
        
        if [ -z "$NEW_NOTE_NAME" ]; then
            exit 1
        fi

        # Logic check: if user didn't type .md, add it
        [[ "$NEW_NOTE_NAME" == *.md ]] || NEW_NOTE_NAME="${NEW_NOTE_NAME}.md"

        touch "$NOTES_DIR/$NEW_NOTE_NAME" 
        "$TERMINAL_EMULATOR" -e nvim "$NOTES_DIR/$NEW_NOTE_NAME"
    fi
fi
