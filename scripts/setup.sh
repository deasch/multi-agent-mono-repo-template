#!/usr/bin/env bash
# One-command environment setup for this project repo.
# Works on macOS, Linux, and Windows via Git Bash / WSL.
# See scripts/setup.ps1 for native Windows PowerShell.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

echo "==> Setting up $(basename "$REPO_ROOT")"

# 1. Initialize git submodules (private-workspace/, packages/*, etc.), if
#    any exist. It's expected and fine for this root to have no .git at
#    all — it's meant to stay a plain local folder for config/orchestration
#    (see packages/README.md, "Note on git activity"); packages added via
#    scripts/add-package.sh fall back to plain git clones in that case, so
#    there's nothing to submodule-init here.
if [ -f ".gitmodules" ] && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "==> Initializing git submodules"
  git submodule update --init --recursive
else
  echo "==> No git submodules to initialize here (root has no .git, or no .gitmodules) — that's fine"
fi

# 2. Resolve/create the private workspace, if not using the submodule model.
if [ -d "private-workspace" ] && [ "$(ls -A private-workspace 2>/dev/null)" ]; then
  echo "==> Private workspace found at ./private-workspace (submodule)"
else
  PROJECT_KEY="$(grep -m1 '^\s*name:' workspace.yaml 2>/dev/null | sed -E 's/.*name:\s*//' | tr -d '"' || true)"
  PROJECT_KEY="${PROJECT_KEY:-unified-ai-workspace}"
  WORKSPACE_ROOT="${AGENT_PRIVATE_WORKSPACE:-$HOME/.agent-private-workspace}"
  TARGET="$WORKSPACE_ROOT/$PROJECT_KEY"
  if [ -d "$TARGET" ]; then
    echo "==> Private workspace found at $TARGET"
  else
    echo "==> No private workspace found. Create one with:"
    echo "      mkdir -p \"$TARGET\""
    echo "    Then copy templates from private/*.example into it."
    echo "    See private/README.md for details."
  fi
fi

# 3. Install dependencies for any detected package managers, if present.
if [ -f "package.json" ] && command -v npm >/dev/null 2>&1; then
  echo "==> Installing npm dependencies"
  npm install
fi
if [ -f "requirements.txt" ] && command -v pip >/dev/null 2>&1; then
  echo "==> Installing Python dependencies"
  pip install -r requirements.txt
fi

echo "==> Setup complete. See AGENTS.md and private/README.md to get started."
