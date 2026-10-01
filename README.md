# Build and Deploy Flutter Web

GitHub Actions workflow that builds the Flutter web app from a source branch and deploys the output to the `edubadges-backpack-web` repository.

## What it does

1. Checks out the specified **source branch** (develop / test / acceptance / main)
2. Builds the Flutter web app with the corresponding **flavor**
3. Packages the build into a tarball
4. Pushes the tarball to `edubadges-backpack-web/dist/<branch>/`

### Branch → Flavor mapping

| Source branch | Flavor |
| ------------- | ------ |
| develop       | dev    |
| test          | tst    |
| acceptance    | acc    |
| main          | prod   |

## Prerequisites

- `gh` CLI installed and authenticated: `gh auth login`
- `DEPLOY_TOKEN` secret configured in the repo (pushes to `edubadges-backpack-web`)

## Manual trigger (gh CLI)

The workflow lives on the `build-web` branch. Trigger it from any machine with `gh`:

```bash
# Trigger a single branch
gh workflow run "Build and Deploy Flutter Web" \
  --ref build-web \
  --field source-branch=develop
```

`--ref build-web` — where the workflow file lives
`--field source-branch=...` — which branch to build

### Available options

```bash
gh workflow run "Build and Deploy Flutter Web" --ref build-web --field source-branch=develop
gh workflow run "Build and Deploy Flutter Web" --ref build-web --field source-branch=test
gh workflow run "Build and Deploy Flutter Web" --ref build-web --field source-branch=acceptance
gh workflow run "Build and Deploy Flutter Web" --ref build-web --field source-branch=main
```

### View results

```bash
gh run list --workflow="Build and Deploy Flutter Web"
gh run view <run-id>
```

## Trigger all branches

Builds all 4 branches in sequence (with 5s delay between each):

```bash
./trigger-all.sh
```

This is a convenience wrapper around the gh CLI — same as running the four `gh workflow run` commands above in a loop.

## Notes

- The workflow file is on `build-web`, not on the branches it builds. Use `--ref build-web` always.
- The built web assets go to `edubadges-backpack-web`, not this repo.
