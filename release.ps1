param(
    [Parameter(Position = 0)]
    [ValidatePattern('^(patch|minor|major|prepatch|preminor|premajor|prerelease|\\d+\\.\\d+\\.\\d+(-[0-9A-Za-z.-]+)?)$')]
    [string]$Version = "patch",

    [switch]$Current,

    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

function Exec {
    param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Command)

    Write-Host "> $($Command -join ' ')" -ForegroundColor Cyan

    if ($DryRun) {
        return
    }

    $Exe = $Command[0]
    $Args = @()
    if ($Command.Length -gt 1) {
        $Args = $Command[1..($Command.Length - 1)]
    }

    & $Exe @Args

    if ($LASTEXITCODE -ne 0) {
        throw "Command failed with exit code ${LASTEXITCODE}: $($Command -join ' ')"
    }
}

$RepoRoot = (git rev-parse --show-toplevel 2>$null).Trim()
if (-not $RepoRoot) {
    throw "Not inside a Git repository."
}
Set-Location $RepoRoot

$Status = git status --porcelain
if ($Status) {
    throw "Working tree is not clean. Commit or stash changes before releasing."
}

Exec npm pack --dry-run
Exec gh auth status

$PackageVersion = (node -p "require('./package.json').version").Trim()

if (-not $Current) {
    Exec npm version $Version
    if (-not $DryRun) {
        $PackageVersion = (node -p "require('./package.json').version").Trim()
    }
}

$GitTag = "v$PackageVersion"

if ($DryRun) {
    Write-Host "Dry run stops before tag/push/release." -ForegroundColor Yellow
    exit 0
}

if ($Current) {
    $ExistingTag = git tag --list $GitTag
    if (-not $ExistingTag) {
        Exec git tag -a $GitTag -m $GitTag
    }
}

Exec git push
Exec git push origin $GitTag

$PreviousErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = "SilentlyContinue"
& gh release view $GitTag *> $null
$ReleaseExists = ($LASTEXITCODE -eq 0)
$ErrorActionPreference = $PreviousErrorActionPreference

if (-not $ReleaseExists) {
    Exec gh release create $GitTag --verify-tag --generate-notes --title $GitTag
} else {
    Write-Host "GitHub Release $GitTag already exists; skipping." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Release $GitTag pushed. GitHub Actions will publish npm using secrets.NPM_TOKEN." -ForegroundColor Green
