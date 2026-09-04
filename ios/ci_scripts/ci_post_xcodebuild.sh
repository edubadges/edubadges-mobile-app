#!/bin/sh

# Runs after Xcode Cloud's xcodebuild action, on success and on failure.
# Xcode Cloud only surfaces "exited with non-zero exit-code: 65" in the build
# summary, which says nothing about the cause. This dumps the actual errors out
# of the result bundle into the log so a failure is diagnosable from the web UI.
#
# Deliberately never fails the build: it is a reporting step, not a build step.

set +e

echo "===== ci_post_xcodebuild: xcodebuild exit code = ${CI_XCODEBUILD_EXIT_CODE:-unknown} ====="

if [ "${CI_XCODEBUILD_EXIT_CODE:-0}" = "0" ]; then
  echo "Build succeeded; nothing to report."
  exit 0
fi

BUNDLE="${CI_RESULT_BUNDLE_PATH:-/Volumes/workspace/resultbundle.xcresult}"
echo "Result bundle: $BUNDLE"

if [ ! -e "$BUNDLE" ]; then
  echo "No result bundle found - cannot extract errors."
  exit 0
fi

echo "----- errors from result bundle -----"

# Xcode 16+ subcommand; falls back to the legacy API on older toolchains.
JSON="$(xcrun xcresulttool get build-results --path "$BUNDLE" --format json 2>/dev/null)"
if [ -z "$JSON" ]; then
  JSON="$(xcrun xcresulttool get --legacy --format json --path "$BUNDLE" 2>/dev/null)"
fi
if [ -z "$JSON" ]; then
  echo "Could not read the result bundle with xcresulttool."
  exit 0
fi

printf '%s' "$JSON" | /usr/bin/python3 -c '
import json, sys

def direct(data):
    "Xcode 16+ build-results shape: a top-level errors array."
    out = []
    if isinstance(data, dict):
        for key in ("errors", "warnings"):
            items = data.get(key)
            if isinstance(items, list):
                for e in items:
                    if isinstance(e, dict):
                        msg = e.get("message")
                        if isinstance(msg, str) and msg.strip():
                            out.append((e.get("issueType") or key,
                                        e.get("targetName") or "",
                                        msg.strip()))
            if key == "errors" and out:
                break
    return out

def walk(node, out):
    "Legacy shape: values wrapped in _value; find anything issue-shaped."
    if isinstance(node, dict):
        msg = node.get("message")
        if isinstance(msg, dict):
            msg = msg.get("_value")
        if isinstance(msg, str) and msg.strip():
            t = node.get("targetName") or ""
            if isinstance(t, dict):
                t = t.get("_value", "")
            k = node.get("issueType") or ""
            if isinstance(k, dict):
                k = k.get("_value", "")
            out.append((k or "issue", t, msg.strip()))
        for v in node.values():
            walk(v, out)
    elif isinstance(node, list):
        for v in node:
            walk(v, out)

try:
    data = json.load(sys.stdin)
except Exception as exc:
    print("Could not parse result bundle JSON: " + str(exc))
    sys.exit(0)

found = direct(data)
if not found:
    found = []
    walk(data, found)

seen = set()
n = 0
for kind, target, msg in found:
    key = (target, msg)
    if key in seen:
        continue
    seen.add(key)
    n += 1
    header = "--- " + str(kind)
    if target:
        header = header + " [" + str(target) + "]"
    print("")
    print(header + " ---")
    print(msg)

print("")
if n == 0:
    print("No issue messages found in the result bundle.")
else:
    print("===== " + str(n) + " issue(s) reported above =====")
'

exit 0
