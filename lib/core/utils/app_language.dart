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
}

final appLanguageProvider = Provider<AppLanguage>((ref) {
  final locale = WidgetsBinding.instance.platformDispatcher.locale;
  final languageCode = locale.languageCode.toLowerCase();

  if (languageCode == AppLanguage.dutch.code) {
    return .dutch;
  }

  // Fallback: everything else → English
  return .english;
});