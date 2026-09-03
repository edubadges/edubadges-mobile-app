#!/usr/bin/env bash
#
# Renders deploy/nginx.conf.template for one flavor and writes it to stdout.
#
#   Usage: tool/render_nginx_conf.sh <dev|tst|acc|prod> > default.conf
#
# The Content-Security-Policy has to name the exact API, SurfConext and
# analytics hosts the app talks to. Rather than maintaining that list by hand in
# four places, this reads it out of .env.<flavor> - the same file the app itself
# loads at startup - so the policy cannot drift away from the build.

set -euo pipefail

FLAVOR="${1:-}"
VALID_FLAVORS=(dev tst acc prod)

if [[ -z "$FLAVOR" || ! " ${VALID_FLAVORS[*]} " == *" $FLAVOR "* ]]; then
  echo "usage: $0 <${VALID_FLAVORS[*]}>" >&2
  exit 2
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$REPO_ROOT/.env.$FLAVOR"
TEMPLATE="$REPO_ROOT/deploy/nginx.conf.template"

for required in "$ENV_FILE" "$TEMPLATE"; do
  [[ -f "$required" ]] || { echo "error: $required not found" >&2; exit 1; }
done

# Reads a key from the env file, ignoring comments and blank lines. Takes the
# last occurrence so a duplicated key resolves the same way flutter_dotenv does.
env_value() {
  grep -E "^$1=" "$ENV_FILE" | tail -n 1 | cut -d= -f2- | tr -d '\r'
}

# Reduces a URL to a bare scheme://host[:port] origin, which is what CSP wants.
origin_of() {
  local url="$1"
  [[ -n "$url" ]] || return 0
  printf '%s' "$url" | sed -E 's#^([a-zA-Z][a-zA-Z0-9+.-]*://[^/]+).*#\1#'
}

API_ORIGIN="$(origin_of "$(env_value API_URL)")"
OIDC_ORIGIN="$(origin_of "$(env_value OPEN_ID_URL)")"
ANALYTICS_ORIGIN="$(origin_of "$(env_value PIWIKPRO_BASE_URL)")"
ANALYTICS_ENABLED="$(env_value ENABLE_ANALYTICS)"

if [[ -z "$API_ORIGIN" || -z "$OIDC_ORIGIN" ]]; then
  echo "error: API_URL and OPEN_ID_URL must be set in .env.$FLAVOR" >&2
  exit 1
fi

# Only widen the policy for analytics when this flavor actually tracks.
ANALYTICS_CSP=""
if [[ "$ANALYTICS_ENABLED" == "true" && -n "$ANALYTICS_ORIGIN" ]]; then
  ANALYTICS_CSP=" $ANALYTICS_ORIGIN"
fi

python3 - "$TEMPLATE" <<PY
import sys, pathlib
template = pathlib.Path(sys.argv[1]).read_text()
for token, value in {
    "{{API_ORIGIN}}": """$API_ORIGIN""",
    "{{OIDC_ORIGIN}}": """$OIDC_ORIGIN""",
    "{{ANALYTICS_CSP}}": """$ANALYTICS_CSP""",
    "{{FLAVOR}}": """$FLAVOR""",
}.items():
    template = template.replace(token, value)
remaining = [line for line in template.splitlines() if "{{" in line]
if remaining:
    sys.exit("error: unresolved tokens in template:\n" + "\n".join(remaining))
sys.stdout.write(template)
PY
