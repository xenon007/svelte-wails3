# Release helper

Create a new package version, Git tag, npm publication and GitHub Release from a clean checkout.

Examples:

```powershell
# First publication when package.json already contains 0.1.0:
.\release.ps1 -Current

# Subsequent releases:
.\release.ps1 patch
.\release.ps1 minor
.\release.ps1 major
.\release.ps1 0.2.0
.\release.ps1 prerelease -Tag next
```

Or from cmd.exe:

```cmd
release.cmd patch
```

Requirements:

- authenticated npm CLI (`npm login`)
- authenticated GitHub CLI (`gh auth login`)
- clean Git working tree

The script runs `npm pack --dry-run` before changing the version. Then `npm version` creates the version commit and `vX.Y.Z` tag, the commit/tag are pushed, the package is published with public access, and a GitHub Release is created with generated notes.
