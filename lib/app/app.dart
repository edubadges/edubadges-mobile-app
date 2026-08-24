import 'package:edubadges/app/routes.dart';
import 'package:edubadges/app/themes.dart';
import 'package:edubadges/core/constants/route_path.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _handleInitialNotification(),
      );
    }
  }

  Future<void> _handleInitialNotification() async {
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null && mounted) {
      ref.read(appRouter).go(RoutePath.main);
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouter);

    return MaterialApp.router(
      title: 'Edubadges',
      theme: AppThemes.themeForPlatform(AppThemes.lightTheme),
      highContrastTheme: AppThemes.themeForPlatform(AppThemes.highContrastTheme),
      routerConfig: router,
      showSemanticsDebugger: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
    );
  }
}
