#!/bin/bash
# Script to generate Firebase configuration files for different environments/flavors
if [[ $# -eq 0 ]]; then
  echo "Error: No environment specified. Use dev, tst, acc, prod."
  exit 1
fi
case $1 in
  dev)
    flutterfire configure \
      --platforms=android,ios \
      --project=edubadges-dev \
      --out=lib/firebase/firebase_options_develop.dart \
      --ios-bundle-id=nl.surf.edubadges \
      --ios-out=ios/flavors/dev/GoogleService-Info.plist \
      --android-package-name=nl.surf.edubadges \
      --android-out=android/app/src/dev/google-services.json
    ;;

  tst)
    flutterfire configure \
      --platforms=android,ios \
      --project=edubadges-tst \
      --out=lib/firebase/firebase_options_tst.dart \
      --ios-bundle-id=nl.surf.edubadges \
      --ios-out=ios/flavors/tst/GoogleService-Info.plist \
      --android-package-name=nl.surf.edubadges \
      --android-out=android/app/src/tst/google-services.json
    ;;

  acc)
    flutterfire configure \
      --platforms=android,ios \
      --project=edubadges-acc \
      --out=lib/firebase/firebase_options_acceptance.dart \
      --ios-bundle-id=nl.surf.edubadges \
      --ios-out=ios/flavors/acc/GoogleService-Info.plist \
      --android-package-name=nl.surf.edubadges \
      --android-out=android/app/src/acc/google-services.json
    ;;

  prod)
    flutterfire configure \
      --platforms=android,ios \
      --project=edubadges-prod \
      --out=lib/firebase/firebase_options_production.dart \
      --ios-bundle-id=nl.surf.edubadges \
      --ios-out=ios/flavors/prod/GoogleService-Info.plist \
      --android-package-name=nl.surf.edubadges \
      --android-out=android/app/src/prod/google-services.json
    ;;
  *)
    echo "Error: Invalid environment specified. Use dev, tst, acc, prod."
    exit 1
    ;;
esac

# Fix FlutterFire build scripts to be non-blocking
if [ -f "ios/Runner.xcodeproj/project.pbxproj" ]; then
  echo "Fixing FlutterFire build scripts to be non-blocking..."
  
  # Fix upload-crashlytics-symbols script
  if grep -q "flutterfire upload-crashlytics-symbols" ios/Runner.xcodeproj/project.pbxproj && ! grep -q "set +e" ios/Runner.xcodeproj/project.pbxproj; then
    sed -i '' 's|shellScript = "\\n#!/bin/bash\\n|shellScript = "\\n#!/bin/bash\\nset +e\\n|g' ios/Runner.xcodeproj/project.pbxproj
    sed -i '' 's|--build-configuration=\${CONFIGURATION}\\n";|--build-configuration=\${CONFIGURATION} || echo "Warning: Crashlytics symbol upload failed, but continuing build..."\\n";|g' ios/Runner.xcodeproj/project.pbxproj
  fi
  
  # Fix bundle-service-file script
  if grep -q "flutterfire bundle-service-file" ios/Runner.xcodeproj/project.pbxproj && ! grep -q "Warning: FlutterFire bundle-service-file failed" ios/Runner.xcodeproj/project.pbxproj; then
    # Ensure set +e is present (might have been added by previous fix)
    if ! grep -q "set +e" ios/Runner.xcodeproj/project.pbxproj; then
      sed -i '' 's|shellScript = "\\n#!/bin/bash\\n|shellScript = "\\n#!/bin/bash\\nset +e\\n|g' ios/Runner.xcodeproj/project.pbxproj
    fi
    sed -i '' 's|--apple-project-path="${SRCROOT}"\\n";|--apple-project-path="${SRCROOT}" || echo "Warning: FlutterFire bundle-service-file failed, but continuing build..."\\n";|g' ios/Runner.xcodeproj/project.pbxproj
  fi
  
  echo "✓ FlutterFire build scripts updated to be non-blocking"
fi
