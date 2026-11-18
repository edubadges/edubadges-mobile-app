#!/bin/sh
#
# Uploads the dSYMs of a Release build to Firebase Crashlytics.
#
# Runs as the "Upload Crashlytics symbols" build phase of the Runner target, so
# every Release build of a flavor (dev/tst/acc/prod scheme) gets its dSYMs
# uploaded: Xcode Cloud, `flutter build ipa --flavor` and Product > Archive
# alike. The flavorless Release configuration is skipped with a warning, since
# it has no Firebase app of its own.
#
# The flavor comes from the build configuration (Release-acc -> acc), and with
# it the Firebase app: ios/flavors/<flavor>/GoogleService-Info.plist.
#
# This replaces the FlutterFire `upload-crashlytics-symbols` phase. That command
# reads the Firebase app per configuration from firebase.json, which this repo
# does not have, so it failed on every build and the failure was swallowed.
#
# A failed upload never fails the build, but it is reported as a build warning
# so it shows up in Xcode and in the Xcode Cloud build summary.

warn() {
  echo "warning: Crashlytics symbol upload: $*"
}

case "$CONFIGURATION" in
  Release-*) FLAVOR="${CONFIGURATION#Release-}" ;;
  Release)
    warn "skipped: the flavorless Release configuration has no GoogleService-Info.plist. Build a flavor scheme (dev/tst/acc/prod) to ship."
    exit 0
    ;;
  *)
    echo "Crashlytics symbol upload: skipped for $CONFIGURATION (only Release configurations ship)."
    exit 0
    ;;
esac

if [ "$DEBUG_INFORMATION_FORMAT" != "dwarf-with-dsym" ]; then
  warn "DEBUG_INFORMATION_FORMAT is '$DEBUG_INFORMATION_FORMAT' for $CONFIGURATION, so there is no dSYM to upload."
  exit 0
fi

PLIST="$PROJECT_DIR/flavors/$FLAVOR/GoogleService-Info.plist"
if [ ! -f "$PLIST" ]; then
  warn "no GoogleService-Info.plist for flavor '$FLAVOR' at $PLIST."
  exit 0
fi

# Firebase comes in through Swift Package Manager, which checks it out under
# <DerivedData>/SourcePackages. OBJROOT stays inside DerivedData even when
# `flutter build ios` moves BUILD_DIR to build/ios; BUILD_DIR covers archives,
# including Xcode Cloud's /Volumes/workspace/DerivedData. The CocoaPods path is
# there in case Firebase ever moves back to pods.
UPLOAD_SYMBOLS=""
for candidate in \
  "${OBJROOT%/Build/*}/SourcePackages/checkouts/firebase-ios-sdk/Crashlytics/upload-symbols" \
  "${BUILD_DIR%/Build/*}/SourcePackages/checkouts/firebase-ios-sdk/Crashlytics/upload-symbols" \
  "${PODS_ROOT:-/nonexistent}/FirebaseCrashlytics/upload-symbols"; do
  if [ -x "$candidate" ]; then
    UPLOAD_SYMBOLS="$candidate"
    break
  fi
done

if [ -z "$UPLOAD_SYMBOLS" ]; then
  warn "could not find Crashlytics' upload-symbols tool (OBJROOT=$OBJROOT, BUILD_DIR=$BUILD_DIR)."
  exit 0
fi

DSYM="$DWARF_DSYM_FOLDER_PATH/$DWARF_DSYM_FILE_NAME"
if [ ! -d "$DSYM" ]; then
  warn "no dSYM at $DSYM."
  exit 0
fi

# Upload the whole folder, not only Runner.app.dSYM: a crash can have frames in
# any binary the app ships (App.framework with the Dart code, Flutter.framework,
# the plugin and pod frameworks), and Crashlytics asks for each one's dSYM.
# upload-symbols searches the folder recursively.
#
# The upload runs in the foreground so it finishes before Xcode Cloud tears the
# machine down, but a watchdog stops it after UPLOAD_TIMEOUT seconds so a
# stalled network cannot hold up the archive. The watchdog's output goes to
# /dev/null: Xcode waits for every process that still holds the phase's output.
UPLOAD_TIMEOUT="${CRASHLYTICS_UPLOAD_TIMEOUT:-300}"
case "$UPLOAD_TIMEOUT" in
  '' | *[!0-9]* | 0)
    warn "CRASHLYTICS_UPLOAD_TIMEOUT='$UPLOAD_TIMEOUT' is not a positive number of seconds; using 300."
    UPLOAD_TIMEOUT=300
    ;;
esac

echo "Crashlytics symbol upload: $FLAVOR ($PLIST)"
xcrun dwarfdump --uuid "$DSYM" 2>/dev/null

"$UPLOAD_SYMBOLS" -gsp "$PLIST" -p ios "$DWARF_DSYM_FOLDER_PATH" &
upload_pid=$!
(sleep "$UPLOAD_TIMEOUT" && kill "$upload_pid") >/dev/null 2>&1 &
watchdog_pid=$!

wait "$upload_pid"
upload_status=$?
kill "$watchdog_pid" 2>/dev/null

if [ "$upload_status" -ne 0 ]; then
  warn "upload-symbols failed or timed out after ${UPLOAD_TIMEOUT}s for $FLAVOR (exit $upload_status); crashes from this build will not be symbolicated."
fi

exit 0
