import 'dart:async';

import 'package:edubadges/app/app.dart';
import 'package:edubadges/core/constants/env_keys.dart';
import 'package:edubadges/core/constants/environment_config.dart';
import 'package:edubadges/core/constants/route_path.dart';
import 'package:edubadges/core/app_container.dart';
import 'package:edubadges/core/network/network_providers.dart';
import 'package:edubadges/core/utils/logger.dart';
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
import 'package:flutter_piwikpro/flutter_piwikpro.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

String? appFlavor;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting();

  // Configure system UI for edge-to-edge display
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  if (appFlavor == null) {
    const flutterAppFlavor = String.fromEnvironment('FLUTTER_APP_FLAVOR');
    const appFlavorEnv = String.fromEnvironment('APP_FLAVOR');
    if (flutterAppFlavor.isNotEmpty) {
      appFlavor = flutterAppFlavor;
    } else if (appFlavorEnv.isNotEmpty) {
      appFlavor = appFlavorEnv;
    } else {
      appFlavor = 'dev';
    }
  }

  F.appFlavor = Flavor.values.firstWhere(
    (element) => element.name == appFlavor,
  );

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

  // Initialize Firebase
  await Firebase.initializeApp(options: _getFirebaseOptions());

  // Initialize Analytics
  final analyticsEnabled = EnvironmentConfig.instance.enableAnalytics;
  if (analyticsEnabled) {
    await FlutterPiwikPro.sharedInstance.configureTracker(
      baseURL: EnvironmentConfig.instance.piwikProBaseUrl,
      siteId: EnvironmentConfig.instance.piwikProSiteId,
    );
  }

  // Initialize Crashlytics (iOS/Android only)
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

  // Initialize Networking
  final container = ProviderContainer();
  appProviderContainer = container;
  final apiClient = container.read(apiClientProvider);
  await apiClient.init();
  unawaited(_syncBadgeCountOnStartup(container));

  // Navigate to main when a notification is tapped (background).
  FirebaseMessaging.onMessageOpenedApp.listen((_) {
    appGoRouter?.go(RoutePath.main);
  });

  runApp(UncontrolledProviderScope(container: container, child: const App()));
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
