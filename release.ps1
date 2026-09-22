param(
    [Parameter(Position = 0)]
    [ValidatePattern('^(patch|minor|major|prepatch|preminor|premajor|prerelease|\d+\.\d+\.\d+(-[0-9A-Za-z.-]+)?)$')]
    [string]$Version = "patch",

    [string]$Tag = "latest",

    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

function Exec {
    param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Command)

    Write-Host "> $($Command -join ' ')" -ForegroundColor Cyan

    if ($DryRun) {
        return
    }

    & $Command[0] $Command[1..($Command.Length - 1)]

    if ($LASTEXITCODE -ne 0) {
        throw "Command failed with exit code $LASTEXITCODE: $($Command -join ' ')"
    }
}

# Always run from repository root.
$RepoRoot = (git rev-parse --show-toplevel 2>$null).Trim()
if (-not $RepoRoot) {
    throw "Not inside a Git repository."
}
Set-Location $RepoRoot

# The release must be reproducible and must not include uncommitted changes.
$Status = git status --porcelain
if ($Status) {
    throw "Working tree is not clean. Commit or stash changes before releasing."
}

# Verify required CLIs and authentication before changing package.json/tagging.
Exec npm --version
Exec gh --version

if (-not $DryRun) {
    npm whoami | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "npm authentication failed. Run 'npm login' first."
    }

    gh auth status
    if ($LASTEXITCODE -ne 0) {
        throw "GitHub CLI authentication failed. Run 'gh auth login' first."
    }
}

# Catch package errors before creating a version commit/tag.
Exec npm pack --dry-run

# npm version updates package.json, creates a commit and annotated git tag vX.Y.Z.
Exec npm version $Version

if ($DryRun) {
    Write-Host "Dry run stops before push/publish/release because no real version/tag was created." -ForegroundColor Yellow
    exit 0
}

$PackageVersion = (node -p "require('./package.json').version").Trim()
$PackageName = (node -p "require('./package.json').name").Trim()
$GitTag = "v$PackageVersion"

Write-Host ""
Write-Host "Publishing $PackageName@$PackageVersion ($GitTag)" -ForegroundColor Green

# Push the version commit and tag first, so npm metadata can point to an existing Git tag.
Exec git push
Exec git push origin $GitTag

# Scoped packages must be explicitly public on initial publish.
Exec npm publish --access public --tag $Tag

# Create a GitHub release and let GitHub generate notes from commits/PRs.
Exec gh release create $GitTag --verify-tag --generate-notes --title $GitTag

Write-Host ""
Write-Host "Released $PackageName@$PackageVersion" -ForegroundColor Green
Write-Host "npm: https://www.npmjs.com/package/$PackageName"
Write-Host "GitHub tag/release: $GitTag"
