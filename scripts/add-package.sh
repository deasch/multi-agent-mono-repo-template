#!/usr/bin/env bash
# Import an existing repo (GitHub, GHE, GitLab, or any git host) into
# packages/<name>, so it becomes a package of this repo without merging its
# git history into this repo's history.
#
# The root repo does NOT need its own `.git` for this to work, and never
# will unless you choose to add one yourself:
#   - If the root IS a git repo: adds the package as a git submodule
#     (tracks a URL + pinned commit SHA pointer in .gitmodules).
#   - If the root is NOT a git repo (the common case — this root is meant
#     to stay a plain local folder for config/orchestration; see
#     packages/README.md, "Note on git activity"): plain `git clone`s the
#     package instead. The package still gets its own full, independent git
#     repo/history — only the root-level pointer tracking is skipped.
#     This is expected and fine, not a degraded mode.
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

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "==> Adding $URL as $TARGET (git submodule)"
  git submodule add "$URL" "$TARGET"
  MODE="submodule"
else
  echo "==> Root repo has no .git (this is expected — see packages/README.md,"
  echo "    'Note on git activity'); cloning $URL directly into $TARGET"
  echo "    instead of adding it as a submodule pointer."
  git clone "$URL" "$TARGET"
  MODE="clone"
fi

if [ -f "$TARGET/.gitkeep" ]; then
  rm -f "packages/.gitkeep" 2>/dev/null || true
fi

if [ "$MODE" = "submodule" ]; then
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
else
  cat <<EOF

Added (plain clone — no root-level pointer to commit, since the root has
no .git). Next steps:
  1. Wire its build/test/lint commands into workspace.yaml under "tasks"
     (and shared/tasks.md) so agents and IDEs can discover them.
  2. Give it a clear README.md if it doesn't already have one.
  3. Work inside "$TARGET" as its own independent git repo (its own
     remote/branches/history) — commit and push there as usual.
See packages/README.md for details.
EOF
fi
