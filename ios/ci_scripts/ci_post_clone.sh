#!/bin/sh

# Fail this script if any subcommand fails.
set -e

# The default execution directory of this script is the ci_scripts directory.
cd $CI_PRIMARY_REPOSITORY_PATH # change working directory to the root of your cloned repo.

# Install Flutter using git.
#
# Pin the exact version the team develops against. Tracking the `stable` branch
# means every run silently picks up whatever Flutter released most recently, so
# an SDK change breaks the build with no commit on our side. That is what broke
# this pipeline: a newer stable made PreviewThemeData abstract, which fails the
# Dart compile in lib/core/widgets/preview_app.dart.
#
# Bump this deliberately, together with a local `flutter upgrade`.
FLUTTER_VERSION="3.41.3"
git clone https://github.com/flutter/flutter.git --depth 1 -b "$FLUTTER_VERSION" $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"
flutter --version

# Install Flutter artifacts for iOS (--ios), or macOS (--macos) platforms.
flutter precache --ios

# Install Flutter dependencies.
flutter pub get

# Configure iOS build files for the scheme Xcode Cloud will archive (dev/tst/acc/prod).
FLAVOR="${CI_XCODE_SCHEME:-dev}"
flutter build ios --config-only --release --flavor "$FLAVOR"

# Activate flutter fire cli
dart pub global activate flutterfire_cli

# Install CocoaPods using Homebrew.
HOMEBREW_NO_AUTO_UPDATE=1 # disable homebrew's automatic updates.
brew install cocoapods

# Install CocoaPods dependencies.
cd ios && pod install # run `pod install` in the `ios` directory.

# xcodebuild reads Package.swift when it opens the workspace, and Flutter
# regenerates that manifest with its own hardcoded minimum iOS version (lower
# than the 15.0 the Firebase SPM plugins require). Make sure the manifest is at
# 15.0 before the archive starts; SPM otherwise fails the build during planning
# with "requires minimum platform version 15.0 ... but this target supports 13.0".
PACKAGE_SWIFT="$CI_PRIMARY_REPOSITORY_PATH/ios/Flutter/ephemeral/Packages/FlutterGeneratedPluginSwiftPackage/Package.swift"
if [ -f "$PACKAGE_SWIFT" ]; then
  /usr/bin/sed -i '' -E 's/\.iOS\("(9|1[0-4])(\.[0-9]+)?"\)/.iOS("15.0")/g' "$PACKAGE_SWIFT"
  echo "FlutterGeneratedPluginSwiftPackage platform: $(grep -o '\.iOS("[0-9.]*")' "$PACKAGE_SWIFT" || true)"
fi

exit 0
