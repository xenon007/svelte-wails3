param(
    [Parameter(Position = 0)]
    [ValidatePattern('^(patch|minor|major|prepatch|preminor|premajor|prerelease|\\d+\\.\\d+\\.\\d+(-[0-9A-Za-z.-]+)?)$')]
    [string]$Version = "patch",

    [string]$Tag = "latest",

    [switch]$Current,

    [string]$Otp,

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

Exec npm pack --dry-run

$PackageVersion = (node -p "require('./package.json').version").Trim()
$PackageName = (node -p "require('./package.json').name").Trim()

if (-not $Current) {
    Exec npm version $Version
    if (-not $DryRun) {
        $PackageVersion = (node -p "require('./package.json').version").Trim()
    }
}

$GitTag = "v$PackageVersion"

if ($DryRun) {
    Write-Host "Dry run stops before publish/tag/push/release." -ForegroundColor Yellow
    exit 0
}

if ($Current) {
    $ExistingTag = git tag --list $GitTag
    if (-not $ExistingTag) {
        Exec git tag -a $GitTag -m $GitTag
    }
}

Write-Host ""
Write-Host "Releasing $PackageName@$PackageVersion ($GitTag)" -ForegroundColor Green

$Published = $false
npm view "$PackageName@$PackageVersion" version --json *> $null
if ($LASTEXITCODE -eq 0) {
    $Published = $true
    Write-Host "$PackageName@$PackageVersion is already present on npm; skipping publish." -ForegroundColor Yellow
}

if (-not $Published) {
    $PublishArgs = @("publish", "--access", "public", "--tag", $Tag)
    if ($Otp) {
        $PublishArgs += @("--otp", $Otp)
    }
    Exec npm @PublishArgs
}

Exec git push
Exec git push origin $GitTag

gh release view $GitTag *> $null
if ($LASTEXITCODE -ne 0) {
    Exec gh release create $GitTag --verify-tag --generate-notes --title $GitTag
} else {
    Write-Host "GitHub Release $GitTag already exists; skipping." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Released $PackageName@$PackageVersion" -ForegroundColor Green
Write-Host "npm: https://www.npmjs.com/package/$PackageName"
Write-Host "GitHub tag/release: $GitTag"
