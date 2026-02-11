
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

String? languageCodeToString(String? langCode, BuildContext context) {
  final l10n = AppLocalizations.of(context);
  
  switch (langCode) {
    case 'nl_NL':
      return l10n.languageDutch;
    case 'en_EN':
      return l10n.languageEnglish;
  }

  return null;
}

/// Selects the appropriate localized string based on the language code
String getLocalizedString(String? dutch, String? english, String langCode) {
  final String? preferred;
  final String? fallback;

  switch (langCode) {
    case 'nl':
      preferred = dutch;
      fallback = english;
      break;
    case 'en':
      preferred = english;
      fallback = dutch;
      break;
    default:
      // Unknown language code - default to English, then Dutch
      preferred = english;
      fallback = dutch;
  }

  return preferred ?? fallback ?? 'Unknown';
}

String filterBadMarkdown(String md) {
   // Remove lines that are just > with optional whitespace
  return md.replaceAll(RegExp(r'^>\s*$', multiLine: true), '');
}