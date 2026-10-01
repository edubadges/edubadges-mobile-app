#!/usr/bin/env bash
set -euo pipefail

TRIGGER='Build and Deploy Flutter Web'

if ! gh auth status >/dev/null 2>&1; then
    echo "You need to login: gh auth login"
    exit 1
fi

for branch in develop test acceptance main; do
  echo "→ Triggering for $branch"
  gh workflow run "$TRIGGER" \
    --ref build-web --field source-branch="$branch"
  sleep 5  # rate limit courtesy
done

echo "Done — all 4 dispatched."
