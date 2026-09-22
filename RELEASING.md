# Release helper

The script publishes npm first and only then pushes Git metadata, so a rejected npm publication does not create a new half-finished GitHub release.

## First publication

If `package.json` already contains the version you want:

```powershell
.\release.ps1 -Current
```

If npm requires a one-time password and the CLI does not prompt interactively:

```powershell
.\release.ps1 -Current -Otp 123456
```

## Subsequent releases

```powershell
.\release.ps1 patch
.\release.ps1 minor
.\release.ps1 major
.\release.ps1 0.2.0
.\release.ps1 prerelease -Tag next
```

Requirements:

- npm authenticated with `npm login`
- npm publish authorization through account 2FA or an appropriate granular token
- GitHub CLI authenticated with `gh auth login`
- clean Git working tree

The script is retry-safe if the npm version or GitHub Release already exists.
