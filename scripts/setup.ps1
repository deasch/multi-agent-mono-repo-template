# One-command environment setup for this project repo (native Windows).
# See scripts/setup.sh for macOS/Linux/Git-Bash/WSL.

$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $RepoRoot

Write-Host "==> Setting up $(Split-Path -Leaf $RepoRoot)"

# 1. Initialize git submodules (private-workspace/, packages/*, etc.) if any.
if (Test-Path ".gitmodules") {
    Write-Host "==> Initializing git submodules"
    git submodule update --init --recursive
} else {
    Write-Host "==> No .gitmodules found, skipping submodule init"
}

# 2. Resolve/create the private workspace, if not using the submodule model.
$PrivateWorkspaceDir = Join-Path $RepoRoot "private-workspace"
if ((Test-Path $PrivateWorkspaceDir) -and (Get-ChildItem $PrivateWorkspaceDir -ErrorAction SilentlyContinue)) {
    Write-Host "==> Private workspace found at .\private-workspace (submodule)"
} else {
    $ProjectKey = "unified-ai-workspace"
    $WorkspaceYaml = Join-Path $RepoRoot "workspace.yaml"
    if (Test-Path $WorkspaceYaml) {
        $Match = Select-String -Path $WorkspaceYaml -Pattern '^\s*name:\s*(.+)$' | Select-Object -First 1
        if ($Match) {
            $ProjectKey = $Match.Matches[0].Groups[1].Value.Trim('"', ' ')
        }
    }
    $WorkspaceRoot = $env:AGENT_PRIVATE_WORKSPACE
    if (-not $WorkspaceRoot) {
        $WorkspaceRoot = Join-Path $env:USERPROFILE ".agent-private-workspace"
    }
    $Target = Join-Path $WorkspaceRoot $ProjectKey
    if (Test-Path $Target) {
        Write-Host "==> Private workspace found at $Target"
    } else {
        Write-Host "==> No private workspace found. Create one with:"
        Write-Host "      New-Item -ItemType Directory -Force -Path `"$Target`""
        Write-Host "    Then copy templates from private\*.example into it."
        Write-Host "    See private\README.md for details."
    }
}

# 3. Install dependencies for any detected package managers, if present.
if ((Test-Path "package.json") -and (Get-Command npm -ErrorAction SilentlyContinue)) {
    Write-Host "==> Installing npm dependencies"
    npm install
}
if ((Test-Path "requirements.txt") -and (Get-Command pip -ErrorAction SilentlyContinue)) {
    Write-Host "==> Installing Python dependencies"
    pip install -r requirements.txt
}

Write-Host "==> Setup complete. See AGENTS.md and private\README.md to get started."
