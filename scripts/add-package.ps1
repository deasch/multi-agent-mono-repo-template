# Import an existing repo (GitHub, GHE, GitLab, or any git host) into
# packages/<name>, so it becomes a package of this repo without merging its
# git history into this repo's history.
#
# The root repo does NOT need its own .git for this to work, and never will
# unless you choose to add one yourself:
#   - If the root IS a git repo: adds the package as a git submodule
#     (tracks a URL + pinned commit SHA pointer in .gitmodules).
#   - If the root is NOT a git repo (the common case -- this root is meant
#     to stay a plain local folder for config/orchestration; see
#     packages/README.md, "Note on git activity"): plain `git clone`s the
#     package instead. The package still gets its own full, independent git
#     repo/history -- only the root-level pointer tracking is skipped.
#     This is expected and fine, not a degraded mode.
#
# Usage:
#   scripts/add-package.ps1 <git-url> [package-name]
#
# Examples:
#   scripts/add-package.ps1 git@github.com:my-org/my-service.git
#   scripts/add-package.ps1 https://github.ghe.example.com/my-org/my-lib.git my-lib
#
# AGENTS: just run this script directly with the URL -- it already detects
# whether the root has .git and picks submodule vs. plain-clone mode
# internally (see above). Don't manually pre-check with Set-Location/git
# rev-parse/Test-Path .git etc. before calling it; that's redundant and
# more likely to hit a tool's own command-approval/sandbox limits than
# this single script invocation is.

param(
    [Parameter(Mandatory = $true)]
    [string]$Url,

    [Parameter(Mandatory = $false)]
    [string]$Name
)

$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $RepoRoot

if (-not $Name) {
    $Name = [System.IO.Path]::GetFileNameWithoutExtension($Url)
}

$Target = "packages/$Name"

if (Test-Path $Target) {
    Write-Error "packages/$Name already exists. Choose a different name or remove it first."
    exit 1
}

git rev-parse --is-inside-work-tree *> $null
if ($LASTEXITCODE -eq 0) {
    Write-Host "==> Adding $Url as $Target (git submodule)"
    git submodule add $Url $Target
    $Mode = "submodule"
} else {
    Write-Host "==> Root repo has no .git (this is expected -- see packages/README.md,"
    Write-Host "    'Note on git activity'); cloning $Url directly into $Target"
    Write-Host "    instead of adding it as a submodule pointer."
    git clone $Url $Target
    $Mode = "clone"
}

$GitkeepPath = Join-Path $Target ".gitkeep"
if (Test-Path $GitkeepPath) {
    Remove-Item -Force "packages/.gitkeep" -ErrorAction SilentlyContinue
}

Write-Host ""
if ($Mode -eq "submodule") {
    Write-Host "Added. Next steps:"
    Write-Host "  1. Commit .gitmodules and the new submodule gitlink:"
    Write-Host "       git add .gitmodules `"$Target`""
    Write-Host "       git commit -m `"Add $Name as a package (submodule)`""
    Write-Host "  2. Wire its build/test/lint commands into workspace.yaml under `"tasks`""
    Write-Host "     (and shared/tasks.md) so agents and IDEs can discover them."
    Write-Host "  3. Give it a clear README.md if it doesn't already have one."
    Write-Host "See packages/README.md for details."
} else {
    Write-Host "Added (plain clone -- no root-level pointer to commit, since the root has"
    Write-Host "no .git). Next steps:"
    Write-Host "  1. Wire its build/test/lint commands into workspace.yaml under `"tasks`""
    Write-Host "     (and shared/tasks.md) so agents and IDEs can discover them."
    Write-Host "  2. Give it a clear README.md if it doesn't already have one."
    Write-Host "  3. Work inside `"$Target`" as its own independent git repo (its own"
    Write-Host "     remote/branches/history) -- commit and push there as usual."
    Write-Host "See packages/README.md for details."
}
