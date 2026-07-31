#!/usr/bin/env bash
# Import an existing repo (GitHub, GHE, GitLab, or any git host) into
# packages/<name> as a git submodule, so it becomes a package of this repo
# without merging its git history into this repo's history.
#
# Usage:
#   scripts/add-package.sh <git-url> [package-name]
#
# Examples:
#   scripts/add-package.sh git@github.com:my-org/my-service.git
#   scripts/add-package.sh https://github.ghe.example.com/my-org/my-lib.git my-lib

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

URL="${1:-}"
if [ -z "$URL" ]; then
  echo "Usage: scripts/add-package.sh <git-url> [package-name]" >&2
  exit 1
fi

NAME="${2:-$(basename "$URL" .git)}"
TARGET="packages/$NAME"

if [ -e "$TARGET" ]; then
  echo "packages/$NAME already exists. Choose a different name or remove it first." >&2
  exit 1
fi

echo "==> Adding $URL as $TARGET (git submodule)"
git submodule add "$URL" "$TARGET"

if [ -f "$TARGET/.gitkeep" ]; then
  rm -f "packages/.gitkeep" 2>/dev/null || true
fi

cat <<EOF

Added. Next steps:
  1. Commit .gitmodules and the new submodule gitlink:
       git add .gitmodules "$TARGET"
       git commit -m "Add $NAME as a package (submodule)"
  2. Wire its build/test/lint commands into workspace.yaml under "tasks"
     (and shared/tasks.md) so agents and IDEs can discover them.
  3. Give it a clear README.md if it doesn't already have one.
See packages/README.md for details.
EOF
