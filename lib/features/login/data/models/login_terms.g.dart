// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_terms.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginTerms _$LoginTermsFromJson(Map<String, dynamic> json) => $checkedCreate(
  'LoginTerms',
  json,
  ($checkedConvert) {
    final val = LoginTerms(
      termsType: $checkedConvert('terms_type', (v) => v as String? ?? ''),
      institution: $checkedConvert(
        'institution',
        (v) => LoginTerms._institutionFromJson(v),
      ),
      termsUrls: $checkedConvert(
        'terms_urls',
        (v) =>
            (v as List<dynamic>?)
                ?.map((e) => LoginTermsUrl.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      ),
    );
    return val;
  },
  fieldKeyMap: const {'termsType': 'terms_type', 'termsUrls': 'terms_urls'},
);

Map<String, dynamic> _$LoginTermsToJson(LoginTerms instance) =>
    <String, dynamic>{
      'terms_type': instance.termsType,
      'institution': ?instance.institution,
      'terms_urls': instance.termsUrls.map((e) => e.toJson()).toList(),
    };
