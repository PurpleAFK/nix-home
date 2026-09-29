#!/usr/bin/env bash
set -euo pipefail
VAULT="$HOME/convergence"
cd "$VAULT"
RESULT=$(rg --line-number --no-heading --color=always --smart-case "${1:-}" \
  | fzf --ansi --delimiter=':' \
        --preview 'bat --color=always --line-range :500 {1} --highlight-line {2}' \
        --preview-window='right:60%')
[ -z "$RESULT" ] && exit 0
FILE=$(echo "$RESULT" | cut -d: -f1)
LINE=$(echo "$RESULT" | cut -d: -f2)
exec nvim "+${LINE}" "$FILE"
