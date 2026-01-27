import 'package:collection/collection.dart';
import 'package:edubadges/core/utils/app_language.dart';
import 'package:edubadges/features/login/data/models/login_terms_url.dart';

class LoginTerms {
  final String termsType;
  final String? institution;
  final List<LoginTermsUrl> termsUrls;

  LoginTerms({
    required this.termsType,
    this.institution,
    required this.termsUrls,
  });

  factory LoginTerms.fromJson(Map<String, dynamic> json) {
    final institutionData = json['institution'];
    String? institutionName;
    if (institutionData is Map<String, dynamic>) {
      institutionName = institutionData['name'] as String?;
    } else if (institutionData is String) {
      institutionName = institutionData;
    }

    var urls = <LoginTermsUrl>[];
    if (json['terms_urls'] != null) {
      urls = (json['terms_urls'] as List)
          .map((i) => LoginTermsUrl.fromJson(i as Map<String, dynamic>))
          .toList();
    }

    return LoginTerms(
      termsType: json['terms_type'] as String? ?? '',
      institution: institutionName,
      termsUrls: urls,
    );
  }

  Map<String, dynamic> toJson() => {
    'terms_type': termsType,
    'institution': institution,
    'terms_urls': termsUrls.map((e) => e.toJson()).toList(),
  };
}

extension LoginTermsUrlListExtension on List<LoginTermsUrl> {
  String urlForLanguage(String langCode) {
    if (isEmpty) {
      throw StateError('No terms URLs available');
    }

    final normalized = langCode.toLowerCase().trim();

    // 1. Exact match
    final exact = firstWhereOrNull((u) => u.language.toLowerCase() == normalized);
    if (exact != null) return exact.url;

    // 2. Fallback language (English)
    final fallback = firstWhereOrNull((u) => u.language.toLowerCase() == AppLanguage.fallbackLanguageCode);
    if (fallback != null) return fallback.url;

    // 3. Last resort: first one (better than crashing in production)
    return first.url;
  }
}
