import 'dart:async';

import 'package:edubadges/app/app.dart';
import 'package:edubadges/core/analytics/piwik_pro_analytics.dart';
import 'package:edubadges/core/app_container.dart';
import 'package:edubadges/core/auth/dev_auth_bootstrap.dart';
import 'package:edubadges/core/auth/web_auth_bootstrap.dart';
import 'package:edubadges/core/constants/env_keys.dart';
import 'package:edubadges/core/constants/environment_config.dart';
import 'package:edubadges/core/constants/route_path.dart';
import 'package:edubadges/core/network/network_providers.dart';
import 'package:edubadges/core/storage/storage_providers.dart';
import 'package:edubadges/core/utils/logger.dart';
import 'package:edubadges/core/utils/url_strategy.dart';
import 'package:edubadges/features/badges_overview/presentation/providers/badges_overview_providers.dart';
import 'package:edubadges/firebase/firebase_options_acceptance.dart'
    as firebase_acc;
import 'package:edubadges/firebase/firebase_options_develop.dart'
    as firebase_dev;
import 'package:edubadges/firebase/firebase_options_production.dart'
    as firebase_prod;
import 'package:edubadges/firebase/firebase_options_tst.dart' as firebase_tst;
import 'package:edubadges/flavors.dart';
import 'package:edubadges/shared/presentation/providers/app_badge_providers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';

String? appFlavor;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  configureAppUrlStrategy();

  if (kIsWeb) {
    GoRouter.optionURLReflectsImperativeAPIs = true;
  }

  await initializeDateFormatting();

  if (!kIsWeb) {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  F.appFlavor = _resolveFlavor();

  logger.i('App flavor: ${F.appFlavor.name}');

  await dotenv.load(fileName: F.envFileName);

  EnvironmentConfig.instance.init(
    apiUrl: dotenv.env[EnvKeys.apiUrl] ?? '',
    openIdUrl: dotenv.env[EnvKeys.openIdUrl] ?? '',
    openIdClientId: dotenv.env[EnvKeys.openIdClientId] ?? '',
    enableAnalytics: dotenv.env[EnvKeys.enableAnalytics] == 'true',
    enableCrashlytics: dotenv.env[EnvKeys.enableCrashlytics] == 'true',
    publicCollectionBaseUrl: dotenv.env[EnvKeys.publicCollectionBaseUrl] ?? '',
    piwikProBaseUrl: dotenv.env[EnvKeys.piwikProBaseUrl] ?? '',
    piwikProSiteId: dotenv.env[EnvKeys.piwikProSiteId] ?? '',
  );

  if (!kIsWeb) {
    await Firebase.initializeApp(options: _getFirebaseOptions());
  } else {
    logger.i('Skipping Firebase initialization on web until configured');
  }

  final bool analyticsEnabled = EnvironmentConfig.instance.enableAnalytics;
  await PiwikProAnalytics.instance.initialize(
    baseUrl: EnvironmentConfig.instance.piwikProBaseUrl,
    siteId: EnvironmentConfig.instance.piwikProSiteId,
    enabled: analyticsEnabled,
  );

  if (!kIsWeb) {
    final crashlyticsEnabled = EnvironmentConfig.instance.enableCrashlytics;
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
      crashlyticsEnabled,
    );

    if (crashlyticsEnabled) {
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    }
  }

  logger.i('''Environment Configuration
  Flavor: ${F.appFlavor.name}
  API URL: ${dotenv.env[EnvKeys.apiUrl]}
  Analytics Enabled: ${dotenv.env[EnvKeys.enableAnalytics] == 'true'}
  Crashlytics Enabled: ${dotenv.env[EnvKeys.enableCrashlytics] == 'true'}''');

  final container = ProviderContainer();
  appProviderContainer = container;
  await _loadPreferences(container);
  final apiClient = container.read(apiClientProvider);
  await apiClient.init();
  await applyDevAccessTokenIfDefined(container);
  await completeWebLoginRedirect(container);
  if (!kIsWeb) {
    unawaited(_syncBadgeCountOnStartup(container));
  }

  if (!kIsWeb) {
    FirebaseMessaging.onMessageOpenedApp.listen((_) {
      appGoRouter?.go(RoutePath.main);
    });
  }

  runApp(UncontrolledProviderScope(container: container, child: const App()));
}

/// Resolves the build flavor, failing loudly instead of silently guessing.
///
/// Mobile builds get `FLUTTER_APP_FLAVOR` for free from `flutter build --flavor`.
/// Web has no `--flavor`, so it must be passed explicitly with
/// `--dart-define=APP_FLAVOR=<flavor>`. Without this guard a web deployment that
/// forgot the define would silently ship a dev-pointed app against the wrong
/// backend and the wrong SurfConext issuer.
Flavor _resolveFlavor() {
  const flutterAppFlavor = String.fromEnvironment('FLUTTER_APP_FLAVOR');
  const appFlavorEnv = String.fromEnvironment('APP_FLAVOR');

  final name = switch (appFlavor) {
    final String preset when preset.isNotEmpty => preset,
    _ when flutterAppFlavor.isNotEmpty => flutterAppFlavor,
    _ when appFlavorEnv.isNotEmpty => appFlavorEnv,
    _ => null,
  };

  final expected = Flavor.values.map((flavor) => flavor.name).join(', ');

  if (name == null) {
    if (kIsWeb) {
      throw _flavorError(
        'No build flavor defined. Web builds must pass '
        '--dart-define=APP_FLAVOR=<flavor>, one of: $expected.',
      );
    }
    appFlavor = Flavor.dev.name;
    return Flavor.dev;
  }

  final match = Flavor.values.where((flavor) => flavor.name == name);
  if (match.isEmpty) {
    throw _flavorError(
      'Unknown build flavor "$name". Expected one of: $expected.',
    );
  }

  appFlavor = name;
  return match.first;
}

/// Prints [message] before returning the error to throw.
///
/// A release web build minifies exception type names, so an uncaught
/// [StateError] surfaces in the browser console as an opaque object and the
/// user just sees the splash screen forever. Printing the text first means the
/// reason is always readable, which matters because this only ever fires on a
/// misconfigured deployment.
///
/// [debugPrint] rather than [logger]: the logger uses the default
/// `DevelopmentFilter`, which drops everything in a release build - exactly the
/// build where this message is needed.
StateError _flavorError(String message) {
  debugPrint('Edubadges startup failed: $message');
  return StateError(message);
}

/// Loads the preferences before anything reads the app language, so a language
/// chosen earlier applies to the first frame and the first API requests.
Future<void> _loadPreferences(ProviderContainer container) async {
  try {
    await container.read(sharedPreferencesProvider.future);
  } catch (error, stackTrace) {
    // Without preferences the app runs in the device language.
    logger.w(
      'Failed to load preferences on startup',
      error: error,
      stackTrace: stackTrace,
    );
  }
}

Future<void> _syncBadgeCountOnStartup(ProviderContainer container) async {
  try {
    await container.read(oidcAuthDataSourceProvider).refreshTokenIfExpired();
    await container.read(badgesOverviewProvider.notifier).refresh();
    final badgesState = await container.read(badgesOverviewProvider.future);
    await container
        .read(appBadgeServiceProvider)
        .syncUnclaimedCount(badgesState.unclaimedCount);
  } catch (error, stackTrace) {
    logger.w(
      'Failed to sync app badge on startup',
      error: error,
      stackTrace: stackTrace,
    );
  }
}

FirebaseOptions _getFirebaseOptions() {
  switch (F.appFlavor) {
    case Flavor.dev:
      return firebase_dev.DefaultFirebaseOptions.currentPlatform;
    case Flavor.tst:
      return firebase_tst.DefaultFirebaseOptions.currentPlatform;
    case Flavor.acc:
      return firebase_acc.DefaultFirebaseOptions.currentPlatform;
    case Flavor.prod:
      return firebase_prod.DefaultFirebaseOptions.currentPlatform;
  }
}
