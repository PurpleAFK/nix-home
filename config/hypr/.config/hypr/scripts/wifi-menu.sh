#!/usr/bin/env zsh

# 1. Get a list of SSIDs, removing duplicates and empty lines
# We use 'nmcli -g' for a clean output and 'fzf' for selection
selected_ssid=$(nmcli -g SSID dev wifi list | sed '/^--/d; /^[[:space:]]*$/d' | sort -u | fzf --prompt="Select Wi-Fi: " --height=40% --border --reverse)

# 2. If nothing was selected (Esc/Ctrl+C), exit
if [[ -z "$selected_ssid" ]]; then
    exit 0
fi

# 3. Check if we already have a saved connection for this SSID
existing_connection=$(nmcli -t -f NAME connection show | grep -w "$selected_ssid")

if [[ -n "$existing_connection" ]]; then
    # 4. If connection exists, just try to up it
    notify-send "Wi-Fi" "Connecting to $selected_ssid..."
    nmcli connection up "$selected_ssid"
else
    # 5. If it's a new network, prompt for password in the terminal
    print -P "%F{cyan}Enter password for $selected_ssid:%f "
    read -s wifi_pass
    echo # New line after password entry
    
    notify-send "Wi-Fi" "Attempting to connect to $selected_ssid..."
    nmcli dev wifi connect "$selected_ssid" password "$wifi_pass"
fi
