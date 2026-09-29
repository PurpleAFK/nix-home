#!/usr/bin/env bash
set -euo pipefail

TOKEN=$(< "${XDG_CONFIG_HOME:-$HOME/.config}/todoist/token")

TEXT=$(printf '' | rofi -dmenu -p "todoist" -l 0 -theme-str 'window {width: 600px;}' || true)
[ -z "${TEXT:-}" ] && exit 0

# JSON-escape the input (handles quotes, backslashes, newlines)
PAYLOAD=$(printf '%s' "$TEXT" | python3 -c 'import json,sys; print(json.dumps({"text": sys.stdin.read()}))')

HTTP=$(curl -sS -o /tmp/todoist.out -w '%{http_code}' \
    -X POST "https://api.todoist.com/api/v1/tasks/quick" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    --data "$PAYLOAD")

if [ "$HTTP" = "200" ] || [ "$HTTP" = "201" ]; then
    notify-send -t 1500 "Todoist" "✓ $TEXT"
else
    notify-send -u critical -t 5000 "Todoist failed ($HTTP)" "$(cat /tmp/todoist.out)"
fi
