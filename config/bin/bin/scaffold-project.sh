#!/usr/bin/env bash
# scaffold-project.sh — bootstrap a Python research project with vault mirror.
#
# usage:   scaffold-project.sh <project-name> [package-name]
# creates: ~/projects/<name>/          (src layout, pyproject, CI, .venv, initial commit)
#          ~/vault/projects/<name>/    (README + log)
#
# env overrides:
#   SCAFFOLD_PYTHON_VERSION   default: 3.11
#   SCAFFOLD_PROJECTS_ROOT    default: $HOME/projects
#   SCAFFOLD_VAULT_ROOT       default: $HOME/vault
#   SCAFFOLD_GITHUB_USER      default: PurpleAFK
#
# does NOT push to GitHub. run:  gh repo create <name> --public --source . --push

set -euo pipefail

# ---- config ------------------------------------------------------------------
PYTHON_VERSION="${SCAFFOLD_PYTHON_VERSION:-3.11}"
PROJECTS_ROOT="${SCAFFOLD_PROJECTS_ROOT:-$HOME/projects}"
VAULT_ROOT="${SCAFFOLD_VAULT_ROOT:-$HOME/convergence}"
GITHUB_USER="${SCAFFOLD_GITHUB_USER:-PurpleAFK}"

AUTHOR_NAME="$(git config --global user.name  2>/dev/null || echo "$GITHUB_USER")"
AUTHOR_EMAIL="$(git config --global user.email 2>/dev/null || echo "${GITHUB_USER,,}@users.noreply.github.com")"

# ---- usage / args ------------------------------------------------------------
usage() {
  cat <<'USAGE'
scaffold-project.sh — bootstrap a Python research project + vault mirror.

usage:   scaffold-project.sh <project-name> [package-name]
creates: ~/projects/<name>/          (src layout, pyproject, CI, .venv, initial commit)
         ~/vault/projects/<name>/    (README + log)

env overrides:
  SCAFFOLD_PYTHON_VERSION   default: 3.11
  SCAFFOLD_PROJECTS_ROOT    default: $HOME/projects
  SCAFFOLD_VAULT_ROOT       default: $HOME/vault
  SCAFFOLD_GITHUB_USER      default: PurpleAFK

does NOT push. run:   gh repo create <name> --public --source . --push
USAGE
  exit "${1:-2}"
}

[[ "${1:-}" == "-h" || "${1:-}" == "--help" ]] && usage 0
[[ $# -lt 1 || $# -gt 2 ]] && usage 2

PROJECT_NAME="$1"
PACKAGE_NAME="${2:-${PROJECT_NAME//-/_}}"

[[ "$PROJECT_NAME" =~ ^[a-z][a-z0-9-]*$ ]] || { echo "error: project name must be lowercase kebab-case; got '$PROJECT_NAME'" >&2; exit 1; }
[[ "$PACKAGE_NAME" =~ ^[a-z][a-z0-9_]*$ ]] || { echo "error: package name must be lowercase snake_case; got '$PACKAGE_NAME'" >&2; exit 1; }

PROJECT_DIR="$PROJECTS_ROOT/$PROJECT_NAME"
VAULT_DIR="$VAULT_ROOT/projects/$PROJECT_NAME"
TODAY="$(date +%Y-%m-%d)"
YEAR="$(date +%Y)"
PY_TAG="py${PYTHON_VERSION//./}"

[[ -e "$PROJECT_DIR" ]] && { echo "error: $PROJECT_DIR already exists" >&2; exit 1; }
[[ -e "$VAULT_DIR"   ]] && { echo "error: $VAULT_DIR already exists"   >&2; exit 1; }

command -v uv  >/dev/null || { echo "error: uv not in PATH"  >&2; exit 1; }
command -v git >/dev/null || { echo "error: git not in PATH" >&2; exit 1; }

# ---- rollback on failure -----------------------------------------------------
_rollback() {
  local code=$?
  if (( code != 0 )); then
    echo "==> failed with exit $code; rolling back" >&2
    rm -rf "$PROJECT_DIR" "$VAULT_DIR" 2>/dev/null || true
  fi
}
trap _rollback EXIT

# ---- scaffold ----------------------------------------------------------------
echo "==> scaffolding $PROJECT_NAME (package: $PACKAGE_NAME, python: $PYTHON_VERSION)"
mkdir -p "$PROJECT_DIR"/{src/"$PACKAGE_NAME",tests,.github/workflows}
cd "$PROJECT_DIR"

# pyproject.toml
cat > pyproject.toml <<EOF
[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[project]
name = "$PROJECT_NAME"
version = "0.0.1"
description = "TODO: one-line description"
readme = "README.md"
requires-python = ">=$PYTHON_VERSION,<3.13"
authors = [{ name = "$AUTHOR_NAME", email = "$AUTHOR_EMAIL" }]
license = { text = "MIT" }
dependencies = []

[project.optional-dependencies]
dev = [
  "pytest>=8",
  "pytest-cov>=5",
  "hypothesis>=6.100",
  "ruff>=0.6",
  "mypy>=1.11",
]

[project.urls]
Repository = "https://github.com/$GITHUB_USER/$PROJECT_NAME"

[tool.hatch.build.targets.wheel]
packages = ["src/$PACKAGE_NAME"]

[tool.ruff]
line-length = 100
target-version = "$PY_TAG"
src = ["src", "tests"]

[tool.ruff.lint]
select = [
  "E", "F", "W",  # pycodestyle + pyflakes
  "I",            # isort
  "UP",           # pyupgrade
  "B",            # bugbear
  "SIM",          # simplify
  "N",            # pep8-naming
  "RUF",          # ruff-specific
  "NPY",          # numpy-specific
]
ignore = [
  "E501",  # long lines: let formatter handle
  "N803",  # allow X, Y, W in signatures (ML convention)
  "N806",  # allow uppercase locals (X_train, W_hh)
]

[tool.ruff.format]
quote-style = "double"

[tool.pytest.ini_options]
minversion = "8.0"
addopts = "-ra -q --strict-markers --strict-config"
testpaths = ["tests"]
pythonpath = ["src"]

[tool.mypy]
python_version = "$PYTHON_VERSION"
strict = true
files = ["src", "tests"]
EOF

# package source
cat > "src/$PACKAGE_NAME/__init__.py" <<EOF
"""$PACKAGE_NAME."""

__version__: str = "0.0.1"
EOF

# tests
: > tests/__init__.py
cat > tests/test_smoke.py <<EOF
"""Smoke test: package imports and reports version."""


def test_import() -> None:
    import $PACKAGE_NAME

    assert $PACKAGE_NAME.__version__ == "0.0.1"
EOF

# .gitignore
cat > .gitignore <<'EOF'
# python
__pycache__/
*.py[cod]
*.egg-info/
build/
dist/
.eggs/

# virtualenv
.venv/
venv/

# testing / caches
.pytest_cache/
.coverage
.coverage.*
htmlcov/
.hypothesis/
.mypy_cache/
.ruff_cache/

# W&B / experiment tracking
wandb/
mlruns/

# data & artifacts (opt-in via git-lfs)
data/
models/
outputs/
checkpoints/
*.pt
*.pth
*.onnx
*.safetensors

# LaTeX build
*.aux
*.log
*.synctex.gz
*.fdb_latexmk
*.fls
*.bcf
*.run.xml
*.out
*.toc

# editor / os
.vscode/
.idea/
*.swp
.DS_Store
EOF

# README
cat > README.md <<EOF
# $PROJECT_NAME

TODO: one-paragraph description.

## Setup

\`\`\`bash
uv venv --python $PYTHON_VERSION
source .venv/bin/activate
uv pip install -e ".[dev]"
\`\`\`

## Check

\`\`\`bash
ruff check .
ruff format --check .
mypy
pytest -v
\`\`\`

## Layout

- \`src/$PACKAGE_NAME/\` — library code
- \`tests/\` — pytest + hypothesis
- \`.github/workflows/test.yml\` — CI (Python $PYTHON_VERSION, ruff + mypy + pytest)

## License

MIT
EOF

# LICENSE
cat > LICENSE <<EOF
MIT License

Copyright (c) $YEAR $AUTHOR_NAME

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF

# CI
cat > .github/workflows/test.yml <<EOF
name: test

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

concurrency:
  group: \${{ github.workflow }}-\${{ github.ref }}
  cancel-in-progress: true

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: install uv
        uses: astral-sh/setup-uv@v3
        with:
          enable-cache: true

      - name: set up python
        run: uv python install $PYTHON_VERSION

      - name: create venv + install
        run: |
          uv venv --python $PYTHON_VERSION
          uv pip install -e ".[dev]"

      - name: ruff check
        run: uv run ruff check .

      - name: ruff format
        run: uv run ruff format --check .

      - name: mypy
        run: uv run mypy

      - name: pytest
        run: uv run pytest -v
EOF

# ---- venv + install ----------------------------------------------------------
echo "==> creating venv (python $PYTHON_VERSION)"
uv venv --python "$PYTHON_VERSION" --quiet

echo "==> installing dev deps"
uv pip install --quiet -e ".[dev]"

echo "==> sanity: ruff + mypy + pytest"
uv run ruff check .
uv run ruff format --check .
uv run mypy
uv run pytest -v

# ---- git ---------------------------------------------------------------------
echo "==> git init on main"
git init -q -b main
git add -A
git -c commit.gpgsign=false commit -q -m "initial: scaffold $PROJECT_NAME"

# ---- vault mirror ------------------------------------------------------------
echo "==> vault mirror at $VAULT_DIR"
mkdir -p "$VAULT_DIR"
cat > "$VAULT_DIR/README.md" <<EOF
# $PROJECT_NAME

- repo: https://github.com/$GITHUB_USER/$PROJECT_NAME
- package: \`$PACKAGE_NAME\`
- python: $PYTHON_VERSION
- started: $TODAY

## Purpose

TODO

## Deliverables

- [ ] TODO

## Related concepts

- [[concepts/...]]

## Related papers

- [[papers/@...]]

## Log

### $TODAY
- Scaffolded via \`scaffold-project.sh\`.
EOF

# commit vault mirror if vault is a git repo
if [[ -d "$VAULT_ROOT/.git" ]]; then
  ( cd "$VAULT_ROOT" \
    && git add "projects/$PROJECT_NAME" \
    && git -c commit.gpgsign=false commit -q -m "project: add $PROJECT_NAME scaffold" ) \
    || echo "warn: vault commit failed (non-fatal)" >&2
fi

# ---- disarm rollback + summary ----------------------------------------------
trap - EXIT

cat <<EOF

==> done

  project:  $PROJECT_DIR
  vault:    $VAULT_DIR
  package:  $PACKAGE_NAME
  python:   $PYTHON_VERSION

next:
  cd $PROJECT_DIR
  source .venv/bin/activate
  # add project-specific deps, e.g.:
  #   uv pip install numpy
  gh repo create $PROJECT_NAME --public --source . --push
  gh run watch
EOF
