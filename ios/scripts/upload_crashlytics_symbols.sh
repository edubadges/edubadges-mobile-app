#!/bin/sh
#
# Uploads the dSYMs of a Release build to Firebase Crashlytics.
#
# Runs as the "Upload Crashlytics symbols" build phase of the Runner target, so
# every archive gets its dSYMs uploaded: Xcode Cloud, `flutter build ipa` and
# Product > Archive alike.
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
echo "Crashlytics symbol upload: $FLAVOR ($PLIST)"
xcrun dwarfdump --uuid "$DSYM" 2>/dev/null
if ! "$UPLOAD_SYMBOLS" -gsp "$PLIST" -p ios "$DWARF_DSYM_FOLDER_PATH"; then
  warn "upload-symbols failed for $FLAVOR; crashes from this build will not be symbolicated."
fi

exit 0
