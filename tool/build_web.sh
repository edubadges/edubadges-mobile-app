#!/usr/bin/env bash
#
# Builds the Edubadges Flutter web app for a single flavor.
#
#   Usage: tool/build_web.sh <dev|tst|acc|prod> [extra flutter build args...]
#
# This is the one supported way to produce a web build. CI, the Dockerfile and
# manual builds all go through it, so the flags below cannot drift apart.
#
# Why the flags matter:
#
#   --dart-define=APP_FLAVOR   flutter_flavorizr's --flavor does not exist on
#                              web, so the flavor must be passed as a define.
#                              main.dart refuses to start a web build without it.
#   --no-web-resources-cdn     serves CanvasKit/skwasm from our own origin
#                              instead of fetching it from www.gstatic.com on
#                              every page load. Required for a strict CSP, for
#                              egress-restricted networks, and to keep visitor
#                              traffic off a third-party CDN.
#   --wasm                     compiles to WebAssembly with an automatic
#                              JavaScript fallback for browsers that need it.
#
# It also prunes unused environment files: all four .env files are declared as
# assets in pubspec.yaml, so without this every deployment would publish every
# environment's configuration at /assets/.env.<flavor>.

set -euo pipefail

FLAVOR="${1:-}"
shift || true

VALID_FLAVORS=(dev tst acc prod)

if [[ -z "$FLAVOR" ]]; then
  echo "error: no flavor given." >&2
  echo "usage: tool/build_web.sh <${VALID_FLAVORS[*]}> [extra flutter build args...]" >&2
  exit 2
fi

if [[ ! " ${VALID_FLAVORS[*]} " == *" $FLAVOR "* ]]; then
  echo "error: unknown flavor '$FLAVOR'. Expected one of: ${VALID_FLAVORS[*]}" >&2
  exit 2
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

echo "==> Building Edubadges web (flavor: $FLAVOR)"

flutter build web \
  --release \
  --wasm \
  --no-web-resources-cdn \
  --dart-define=APP_FLAVOR="$FLAVOR" \
  "$@"

OUT="build/web"

echo "==> Pruning environment files other than .env.$FLAVOR"
for other in "${VALID_FLAVORS[@]}"; do
  if [[ "$other" != "$FLAVOR" && -f "$OUT/assets/.env.$other" ]]; then
    rm -f "$OUT/assets/.env.$other"
    echo "    removed assets/.env.$other"
  fi
done

if [[ ! -f "$OUT/assets/.env.$FLAVOR" ]]; then
  echo "error: assets/.env.$FLAVOR is missing from the build output." >&2
  echo "       The app loads it at startup and will not boot without it." >&2
  exit 1
fi

# CanvasKit must be served from our own origin, not www.gstatic.com.
#
# Note: the gstatic URL always appears in flutter_bootstrap.js, inside the
# ternary that chooses between the local copy and the CDN. Grepping for that URL
# is a false positive - the build config flag below is what actually decides.
if [[ ! -d "$OUT/canvaskit" ]]; then
  echo "error: $OUT/canvaskit is missing - the renderer would be fetched from" >&2
  echo "       a Google CDN at runtime. Check that --no-web-resources-cdn ran." >&2
  exit 1
fi

# Keep every environment except production out of search results. Written as a
# real file rather than an nginx `return`, because nginx does not interpret
# escape sequences in returned strings.
if [[ "$FLAVOR" == "prod" ]]; then
  printf 'User-agent: *\nAllow: /\n' > "$OUT/robots.txt"
else
  printf 'User-agent: *\nDisallow: /\n' > "$OUT/robots.txt"
fi
echo "==> Wrote robots.txt ($([[ "$FLAVOR" == "prod" ]] && echo "indexable" || echo "disallow all"))"

if ! grep -q '"useLocalCanvasKit":true' "$OUT/flutter_bootstrap.js"; then
  echo "error: useLocalCanvasKit is not set in $OUT/flutter_bootstrap.js, so the" >&2
  echo "       renderer would still be fetched from www.gstatic.com at runtime." >&2
  exit 1
fi

echo "==> Done. Output in $OUT ($(du -sh "$OUT" | cut -f1))"
echo "    Serve it at the ROOT of a hostname - the SurfConext redirect URI is"
echo "    derived from the origin, so a sub-path deployment breaks login."
