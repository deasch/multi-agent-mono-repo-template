#!/usr/bin/env bash
# Sanity-check a package submodule before pushing it back to its own remote:
# warns if content that belongs only in this root repo (backlog/roadmap
# notes, handover documents, team-design/workflow-rules content, private
# *.local.* files) looks like it leaked into the package's changes.
#
# This is a best-effort keyword scan, not a guarantee — always review the
# diff yourself before pushing a package to a third-party/external host.
#
# Usage:
#   scripts/check-package-clean.sh <package-name>

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NAME="${1:-}"

if [ -z "$NAME" ]; then
  echo "Usage: scripts/check-package-clean.sh <package-name>" >&2
  exit 1
fi

PKG="$REPO_ROOT/packages/$NAME"
if [ ! -d "$PKG" ]; then
  echo "packages/$NAME not found." >&2
  exit 1
fi

PATTERNS='backlog|roadmap|sprint|handover|requirements/|team-mode-design|workflow-rules|cross-service-context|\.local\.'

echo "==> Checking packages/$NAME for content that should stay in this root repo"
cd "$PKG"

found=0

changed_files="$(git status --porcelain | awk '{print $2}')"
if [ -n "$changed_files" ]; then
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    if echo "$f" | grep -Eiq "$PATTERNS"; then
      echo "  ! Suspicious file path: $f"
      found=1
    fi
  done <<< "$changed_files"
fi

if git diff HEAD 2>/dev/null | grep -Eiq "$PATTERNS"; then
  echo "  ! Suspicious content found in the working diff (matches: $PATTERNS)"
  found=1
fi

if [ "$found" = "1" ]; then
  echo ""
  echo "Review the flagged files/content above before committing or pushing"
  echo "packages/$NAME to its own remote — this repo's proprietary/internal"
  echo "content (backlog items, handover docs, team design, workflow rules,"
  echo "private/*.local.* content) must never leave via a package's own repo."
  exit 1
fi

echo "OK — no obvious markers found. Still review the diff manually before pushing."
