#!/usr/bin/env python3
"""Vault -> Anki sync via AnkiConnect.
Parses START/END blocks in ~/convergence/**/*.md and pushes them.
Idempotent: writes note IDs back as HTML comments after first add."""
from __future__ import annotations

import json
import re
import subprocess
import sys
import urllib.error
import urllib.request
from pathlib import Path

VAULT       = Path.home() / "convergence"
ANKICONNECT = "http://127.0.0.1:8765"
DEFAULT_DECK  = "vault"
DEFAULT_MODEL = "Basic"

BLOCK_RE = re.compile(
    r"^START[ \t]*\n"
    r"(?P<body>.*?)"
    r"^END[ \t]*\n"
    r"(?:[ \t]*\n)?"                                                  # tolerate one blank line
    r"(?:<!--[ \t]*ankiid:[ \t]*(?P<id>\d+)[ \t]*-->[ \t]*\n)?",
    re.MULTILINE | re.DOTALL,
)
DECK_RE = re.compile(r"^TARGET DECK:[ \t]*(.+?)[ \t]*$", re.MULTILINE)
TAGS_RE = re.compile(r"^FILE TAGS:[ \t]*(.+?)[ \t]*$",   re.MULTILINE)


def ac(action, **params):
    payload = json.dumps({"action": action, "version": 6, "params": params}).encode()
    req = urllib.request.Request(
        ANKICONNECT, data=payload,
        headers={"Content-Type": "application/json"},
    )
    with urllib.request.urlopen(req, timeout=15) as r:
        resp = json.load(r)
    if resp.get("error"):
        raise RuntimeError(f"{action}: {resp['error']}")
    return resp["result"]


def parse_basic(body: str):
    """Return (front, back) or None if not a well-formed Basic block."""
    lines = body.strip().splitlines()
    if not lines or lines[0].strip() != "Basic":
        return None
    front, back, in_back = [], [], False
    for ln in lines[1:]:
        if not in_back and ln.startswith("Back:"):
            in_back = True
            tail = ln[len("Back:"):].lstrip()
            if tail:
                back.append(tail)
            continue
        (back if in_back else front).append(ln)
    if not front or not back:
        return None
    return "\n".join(front).strip(), "\n".join(back).strip()


def sync_file(path: Path, deck_cache: set[str]) -> tuple[int, int, int]:
    text = path.read_text(encoding="utf-8")
    m = DECK_RE.search(text)
    deck = m.group(1).strip() if m else DEFAULT_DECK
    m = TAGS_RE.search(text)
    file_tags = m.group(1).split() if m else []

    added = updated = skipped = 0
    new_parts: list[str] = []
    last = 0

    for match in BLOCK_RE.finditer(text):
        parsed  = parse_basic(match.group("body"))
        note_id = match.group("id")
        new_parts.append(text[last:match.end()])
        last = match.end()

        if parsed is None:
            skipped += 1
            continue
        front, back = parsed
        fields = {"Front": front, "Back": back}

        if note_id:
            try:
                ac("updateNoteFields", note={"id": int(note_id), "fields": fields})
                if file_tags:
                    ac("addTags", notes=[int(note_id)], tags=" ".join(file_tags))
                updated += 1
            except RuntimeError as e:
                sys.stderr.write(f"[warn] {path}: update {note_id}: {e}\n")
                skipped += 1
            continue

        if deck not in deck_cache:
            ac("createDeck", deck=deck)
            deck_cache.add(deck)
        try:
            new_id = ac("addNote", note={
                "deckName":  deck,
                "modelName": DEFAULT_MODEL,
                "fields":    fields,
                "options":   {"allowDuplicate": False, "duplicateScope": "deck"},
                "tags":      file_tags,
            })
            new_parts.append(f"<!-- ankiid: {new_id} -->\n")
            added += 1
        except RuntimeError as e:
            sys.stderr.write(f"[warn] {path}: add: {e}\n")
            skipped += 1

    new_parts.append(text[last:])
    new_text = "".join(new_parts)
    if new_text != text:
        path.write_text(new_text, encoding="utf-8")

    return added, updated, skipped


def main() -> int:
    if not VAULT.is_dir():
        sys.stderr.write(f"Vault not found: {VAULT}\n")
        return 2
    try:
        ac("version")
    except (urllib.error.URLError, RuntimeError) as e:
        sys.stderr.write(f"AnkiConnect unreachable at {ANKICONNECT}: {e}\n")
        subprocess.run(["notify-send", "anki-sync", f"AnkiConnect down: {e}"], check=False)
        return 3

    deck_cache: set[str] = set(ac("deckNames"))
    totals = [0, 0, 0]
    for md in sorted(VAULT.rglob("*.md")):
        try:
            a, u, s = sync_file(md, deck_cache)
        except Exception as e:
            sys.stderr.write(f"[error] {md}: {e}\n")
            continue
        totals[0] += a; totals[1] += u; totals[2] += s
        if a or u or s:
            print(f"{md.relative_to(VAULT)}: +{a} ~{u} !{s}")

    msg = f"anki-sync: +{totals[0]} added, ~{totals[1]} updated, !{totals[2]} skipped"
    print(msg)
    subprocess.run(["notify-send", "anki-sync", msg], check=False)
    return 0


if __name__ == "__main__":
    sys.exit(main())
