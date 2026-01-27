
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

String? languageCodeToString(String? langCode, BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  
  switch (langCode) {
    case 'nl_NL':
      return l10n.languageDutch;
    case 'en_EN':
      return l10n.languageEnglish;
  }

  return null;
}

String filterBadMarkdown(String md) {
   // Remove lines that are just > with optional whitespace
  return md.replaceAll(RegExp(r'^>\s*$', multiLine: true), '');
}