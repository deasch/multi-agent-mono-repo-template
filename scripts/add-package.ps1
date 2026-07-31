# Import an existing repo (GitHub, GHE, GitLab, or any git host) into
# packages/<name> as a git submodule, so it becomes a package of this repo
# without merging its git history into this repo's history.
#
# Usage:
#   scripts/add-package.ps1 <git-url> [package-name]
#
# Examples:
#   scripts/add-package.ps1 git@github.com:my-org/my-service.git
#   scripts/add-package.ps1 https://github.ghe.example.com/my-org/my-lib.git my-lib

param(
    [Parameter(Mandatory = $true)]
    [string]$Url,

    [Parameter(Mandatory = $false)]
    [string]$Name
)

$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $RepoRoot

# git submodule add requires the root itself to be a git repo. A fresh
# instance of this template (downloaded as a zip, or copied rather than
# `git clone`d) won't have a `.git` yet -- initialize it automatically so
# importing a package as a submodule works out of the box.
git rev-parse --is-inside-work-tree *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Host "==> No git repository found at $RepoRoot -- running 'git init'"
    git init
    Write-Host "    (root repo initialized; this only tracks config/docs/submodule"
    Write-Host "     pointers here -- see packages/README.md, 'Note on git activity')"
}

if (-not $Name) {
    $Name = [System.IO.Path]::GetFileNameWithoutExtension($Url)
}

$Target = "packages/$Name"

if (Test-Path $Target) {
    Write-Error "packages/$Name already exists. Choose a different name or remove it first."
    exit 1
}

Write-Host "==> Adding $Url as $Target (git submodule)"
git submodule add $Url $Target

$GitkeepPath = Join-Path $Target ".gitkeep"
if (Test-Path $GitkeepPath) {
    Remove-Item -Force "packages/.gitkeep" -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "Added. Next steps:"
Write-Host "  1. Commit .gitmodules and the new submodule gitlink:"
Write-Host "       git add .gitmodules `"$Target`""
Write-Host "       git commit -m `"Add $Name as a package (submodule)`""
Write-Host "  2. Wire its build/test/lint commands into workspace.yaml under `"tasks`""
Write-Host "     (and shared/tasks.md) so agents and IDEs can discover them."
Write-Host "  3. Give it a clear README.md if it doesn't already have one."
Write-Host "See packages/README.md for details."
