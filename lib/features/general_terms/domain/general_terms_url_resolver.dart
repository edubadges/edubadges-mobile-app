import 'package:collection/collection.dart';
import 'package:edubadges/core/utils/app_language.dart';
import 'package:edubadges/features/account/domain/entities/profile_entity.dart';
import 'package:edubadges/features/general_terms/domain/general_terms_constants.dart';
import 'package:edubadges/features/login/data/models/login_terms.dart';
import 'package:edubadges/features/login/data/models/login_user_status.dart';

/// The SURF account terms, as the edubadges web frontend shows them.
///
/// A brand-new account has no terms agreements yet, so the API lists no terms
/// URL until the user has accepted them (SURF-687).
const List<TermsUrlEntity> defaultTermsOfServiceUrls = [
  TermsUrlEntity(
    url:
        'https://raw.githubusercontent.com/edubadges/privacy/master/surf/account-terms-en.md',
    language: 'en',
    excerpt: false,
  ),
  TermsUrlEntity(
    url:
        'https://raw.githubusercontent.com/edubadges/privacy/master/surf/account-terms-nl.md',
    language: 'nl',
    excerpt: false,
  ),
];

/// Resolves the terms URL from login status (used by router redirect at login).
///
/// Never throws: the router calls this inside a redirect, where an exception
/// left the user on the login spinner for good.
String resolveGeneralTermsUrlFromLoginStatus(
  LoginTermsAgreementRequired loginStatus,
  String languageCode,
) {
  final termsAgreement = loginStatus.termsAgreementSet.firstWhereOrNull(
    (element) => element.terms.termsType == GeneralTermsConstants.termsOfServiceType,
  );
  final urls = termsAgreement?.terms.termsUrls;
  if (urls == null || urls.isEmpty) {
    return defaultTermsOfServiceUrls.urlForLanguage(languageCode);
  }
  return urls.urlForLanguage(languageCode);
}

extension TermsUrlEntityListExtension on List<TermsUrlEntity> {
  String urlForLanguage(String langCode) {
    if (isEmpty) {
      throw StateError('No terms URLs available');
    }
    final normalized = langCode.toLowerCase().trim();
    final exact = firstWhereOrNull(
      (u) => u.language.toLowerCase() == normalized,
    );
    if (exact != null) {
      return exact.url;
    }
    final fallback = firstWhereOrNull(
      (u) => u.language.toLowerCase() == AppLanguage.fallbackLanguageCode,
    );
    if (fallback != null) {
      return fallback.url;
    }
    return first.url;
  }
}
