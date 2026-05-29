import 'package:collection/collection.dart';
import 'package:edubadges/core/utils/app_language.dart';
import 'package:edubadges/features/account/domain/entities/profile_entity.dart';
import 'package:edubadges/features/general_terms/domain/general_terms_constants.dart';
import 'package:edubadges/features/login/data/models/login_terms.dart';
import 'package:edubadges/features/login/data/models/login_user_status.dart';

/// Resolves the terms URL from login status (used by router redirect at login).
String resolveGeneralTermsUrlFromLoginStatus(
  LoginTermsAgreementRequired loginStatus,
  String languageCode,
) {
  final termsAgreement = loginStatus.termsAgreementSet.firstWhereOrNull(
    (element) => element.terms.termsType == GeneralTermsConstants.termsOfServiceType,
  );
  if (termsAgreement == null || termsAgreement.terms.termsUrls.isEmpty) {
    throw StateError('No terms of service URL available in login status');
  }
  return termsAgreement.terms.termsUrls.urlForLanguage(languageCode);
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
