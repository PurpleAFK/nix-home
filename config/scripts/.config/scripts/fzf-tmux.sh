#!/bin/bash

# Function to display an error message and exit
error_exit() {
    echo "Error: $1" >&2
    exit 1
}

# Check if fzf is installed
if ! command -v fzf &> /dev/null; then
    error_exit "fzf is not installed. Please install it to use this script."
fi

# Check if zoxide is installed
if ! command -v zoxide &> /dev/null; then
    error_exit "zoxide is not installed. Please install it to use this script."
fi

# Check if tmux is installed
if ! command -v tmux &> /dev/null; then
    error_exit "tmux is not installed. Please install it to use this script."
fi

# Get the list of zoxide directories and pipe them to fzf for selection
# zoxide query -l lists all learned directories
# fzf allows interactive selection
SELECTED_DIR=$(zoxide query -l | fzf --prompt="Select a directory for your tmux session: ")

# Check if a directory was selected
if [ -z "$SELECTED_DIR" ]; then
    echo "No directory selected. Exiting."
    exit 0
fi

# Extract only the base name (project name) from the selected directory path
# This will make the session name just "project" instead of "home-user-project"
SESSION_NAME=$(basename "$SELECTED_DIR")

# Check if a tmux server is running. If not, start one.
# This prevents issues if tmux is not already active
if ! tmux info &> /dev/null; then
    echo "Tmux server not running. Starting a new server."
    # We don't need to start a dummy session, just ensure the server is up
    # A new session will be created or attached to below.
fi

# Check if a tmux session with the generated name already exists
# tmux has-session -t <session_name> returns 0 if session exists, 1 otherwise
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "Attaching to existing tmux session: $SESSION_NAME"
    # Attach to the existing session
    tmux attach-session -t "$SESSION_NAME"
else
    echo "Creating new tmux session: $SESSION_NAME in directory: $SELECTED_DIR"
    # Create a new tmux session
    # -s: specify session name
    # -c: specify working directory for the new session
    tmux new-session -s "$SESSION_NAME" -c "$SELECTED_DIR"
fi

