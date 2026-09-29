#!/usr/bin/env bash
set -euo pipefail
VAULT="$HOME/convergence"
FILE="$VAULT/daily/$(date +%F).md"
if [ ! -f "$FILE" ]; then
  cp "$VAULT/_templates/daily.md" "$FILE"
  sed -i "s|<% tp.date.now(\"YYYY-MM-DD\") %>|$(date +%F)|g" "$FILE"
  sed -i "s|<% tp.date.now(\"dddd\") %>|$(date +%A)|g" "$FILE"
fi
exec nvim "$FILE"
