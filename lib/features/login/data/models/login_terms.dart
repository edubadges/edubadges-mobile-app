import 'package:collection/collection.dart';
import 'package:edubadges/core/utils/app_language.dart';
import 'package:edubadges/features/login/data/models/login_terms_url.dart';
import 'package:json_annotation/json_annotation.dart';

part 'login_terms.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class LoginTerms {
  @JsonKey(defaultValue: '')
  final String termsType;
  @JsonKey(fromJson: _institutionFromJson)
  final String? institution;
  @JsonKey(defaultValue: <LoginTermsUrl>[])
  final List<LoginTermsUrl> termsUrls;

  const LoginTerms({
    required this.termsType,
    this.institution,
    required this.termsUrls,
  });

  factory LoginTerms.fromJson(Map<String, dynamic> json) =>
      _$LoginTermsFromJson(json);

  Map<String, dynamic> toJson() => _$LoginTermsToJson(this);

  static const empty = LoginTerms(termsType: '', termsUrls: <LoginTermsUrl>[]);

  static String? _institutionFromJson(Object? institutionData) {
    if (institutionData is Map<String, dynamic>) {
      return institutionData['name'] as String?;
    }
    if (institutionData is String) {
      return institutionData;
    }
    return null;
  }
}

extension LoginTermsUrlListExtension on List<LoginTermsUrl> {
  String urlForLanguage(String langCode) {
    if (isEmpty) {
      throw StateError('No terms URLs available');
    }

    final normalized = langCode.toLowerCase().trim();

    // 1. Exact match
    final exact = firstWhereOrNull(
      (u) => u.language.toLowerCase() == normalized,
    );
    if (exact != null) return exact.url;

    // 2. Fallback language (English)
    final fallback = firstWhereOrNull(
      (u) => u.language.toLowerCase() == AppLanguage.fallbackLanguageCode,
    );
    if (fallback != null) return fallback.url;

    // 3. Last resort: first one (better than crashing in production)
    return first.url;
  }
}
