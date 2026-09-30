import 'package:collection/collection.dart';
import 'package:edubadges/core/storage/storage_providers.dart';
import 'package:edubadges/core/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppLanguage {
  english,
  dutch;

  static const AppLanguage fallback = english;

  String get code => switch (this) {
    english => 'en',
    dutch  => 'nl',
  };

  Locale get locale => Locale(code);

  String get displayName => switch (this) {
    english => 'English',
    dutch  => 'Nederlands',
  };

  static String get fallbackLanguageCode => fallback.code;

  /// The language for a code or tag such as `nl`, `nl-NL` or `nl_BE`, or null
  /// when the app does not support it.
  static AppLanguage? fromCode(String? code) {
    final String? languageCode = code
        ?.trim()
        .toLowerCase()
        .split(RegExp('[-_]'))
        .first;
    return values.firstWhereOrNull((language) => language.code == languageCode);
  }

  /// The first supported language among the device's preferred [locales], or
  /// [fallback] when there is none.
  ///
  /// Going through the whole list matches how [MaterialApp] picked the UI
  /// language before the app set its locale explicitly.
  static AppLanguage fromLocales(Iterable<Locale> locales) {
    for (final Locale locale in locales) {
      final AppLanguage? language = fromCode(locale.languageCode);
      if (language != null) {
        return language;
      }
    }
    return fallback;
  }
}

/// The language the app is shown in and asks the API for.
///
/// A choice made on the account page is stored on the device. Without one the
/// device language is used, falling back to English.
final appLanguageProvider = NotifierProvider<AppLanguageNotifier, AppLanguage>(
  AppLanguageNotifier.new,
);

class AppLanguageNotifier extends Notifier<AppLanguage> {
  /// Also read by `web/splash.js`, so the loading screen matches the choice.
  static const String storageKey = 'app_language';

  @override
  AppLanguage build() {
    // main() loads the preferences before the first frame, so a stored choice
    // applies from the start. Should they not be loaded yet, the device
    // language is used until they are; watching them rebuilds this then.
    final String? stored = ref
        .watch(sharedPreferencesProvider)
        .value
        ?.getString(storageKey);

    return AppLanguage.fromCode(stored) ??
        AppLanguage.fromLocales(
          WidgetsBinding.instance.platformDispatcher.locales,
        );
  }

  /// Switches the app to [language] immediately and remembers the choice.
  Future<void> setLanguage(AppLanguage language) async {
    state = language;
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      await prefs.setString(storageKey, language.code);
    } catch (error, stackTrace) {
      // The switch already happened; it just won't survive a restart.
      logger.w(
        'Failed to store the app language',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
