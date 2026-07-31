#!/usr/bin/env bash
# Verify every AI-tool instruction file still references the same canonical
# knowledge sources as workspace.yaml, so every agent/IDE has the same
# information at all times. Run this whenever a shared/ doc is added,
# renamed, or its role changes.
#
# This is a best-effort keyword check (does each tool file mention each
# canonical doc at all?), not a semantic diff — it catches "we added a new
# shared doc and forgot to point Copilot/Cursor/Windsurf at it," not subtle
# wording drift. Review the actual sections yourself too.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

MARKERS=(
  "workspace.yaml"
  "shared/security.md"
  "shared/conventions.md"
  "shared/workflows.md"
  "shared/handover.md"
  "shared/requirements.md"
)

STATUS=0

check_file() {
  local label="$1"
  shift
  local content=""
  local p
  for p in "$@"; do
    if [ -f "$REPO_ROOT/$p" ]; then
      content+="$(cat "$REPO_ROOT/$p")"$'\n'
    fi
  done
  if [ -z "$content" ]; then
    echo "! $label not found (checked: $*)"
    STATUS=1
    return
  fi
  local missing=()
  local m
  for m in "${MARKERS[@]}"; do
    if ! grep -qF -- "$m" <<< "$content"; then
      missing+=("$m")
    fi
  done
  if [ "${#missing[@]}" -gt 0 ]; then
    echo "! $label is missing references to: ${missing[*]}"
    STATUS=1
  else
    echo "OK  $label"
  fi
}

echo "==> Checking that every AI tool references the same canonical docs"
check_file "AGENTS.md" "AGENTS.md"
check_file ".claude/CLAUDE.md" ".claude/CLAUDE.md"
check_file ".cursor/rules/*.mdc" .cursor/rules/*.mdc
check_file ".windsurf/rules/*.md" .windsurf/rules/*.md
check_file ".github/copilot-instructions.md" ".github/copilot-instructions.md"

echo ""
if [ "$STATUS" -ne 0 ]; then
  echo "Drift found — update the flagged file(s) to reference the missing doc(s)."
else
  echo "All tool instruction files reference the same canonical docs."
fi
exit $STATUS
