#!/usr/bin/env bash
# vnote <kind> [title]
# kind ∈ {concept, paper, project, cp-problem, blog-post}
set -euo pipefail
VAULT="$HOME/convergence"
KIND="${1:?usage: vnote <kind> [title]}"
shift
TITLE="${*:-}"
[ -z "$TITLE" ] && read -rp "Title: " TITLE
SLUG="$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' \
  | tr -c '[:alnum:]' '-' | sed -E 's/-+/-/g; s/^-|-$//g')"
FILE="$VAULT/$KIND/$SLUG.md"
mkdir -p "$(dirname "$FILE")"
if [ ! -f "$FILE" ]; then
  TEMPLATE="$VAULT/_templates/${KIND}.md"
  if [ -f "$TEMPLATE" ]; then
    cp "$TEMPLATE" "$FILE"
  else
    printf -- "---\ntags: [%s]\ncreated: %s\n---\n# %s\n\n" \
      "$KIND" "$(date +%F)" "$TITLE" > "$FILE"
  fi
  sed -i "s|{{title}}|$TITLE|g" "$FILE"
  sed -i "s|<% tp.date.now(\"YYYY-MM-DD\") %>|$(date +%F)|g" "$FILE"
fi
exec nvim "$FILE"
