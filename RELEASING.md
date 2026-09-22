# Release helper

Publishing to npm is performed by GitHub Actions using the repository secret `NPM_TOKEN`.

## First publication

If `package.json` already contains the version you want:

```powershell
.\release.ps1 -Current
```

## Subsequent releases

```powershell
.\release.ps1 patch
.\release.ps1 minor
.\release.ps1 major
.\release.ps1 0.2.0
```

The script creates/pushes the Git tag and GitHub Release. The `.github/workflows/publish-npm.yml` workflow publishes the tagged version to npm.

If a release must be redone before npm publication:

```powershell
gh release delete v0.1.0 --yes
git push origin :refs/tags/v0.1.0
git tag -d v0.1.0
```
