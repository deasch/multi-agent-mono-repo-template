#!/usr/bin/env bash
# One-command environment setup for this project repo.
# Works on macOS, Linux, and Windows via Git Bash / WSL.
# See scripts/setup.ps1 for native Windows PowerShell.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

echo "==> Setting up $(basename "$REPO_ROOT")"

# 0. A fresh instance of this template (downloaded as a zip, or copied
#    rather than `git clone`d) won't have a `.git` yet. Submodules require
#    the root itself to be a git repo, so initialize it automatically.
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "==> No git repository found at $REPO_ROOT — running 'git init'"
  git init
fi

# 1. Initialize git submodules (private-workspace/, packages/*, etc.) if any.
if [ -f ".gitmodules" ]; then
  echo "==> Initializing git submodules"
  git submodule update --init --recursive
else
  echo "==> No .gitmodules found, skipping submodule init"
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
