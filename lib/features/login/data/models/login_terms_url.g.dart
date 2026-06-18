// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_terms_url.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginTermsUrl _$LoginTermsUrlFromJson(Map<String, dynamic> json) =>
    $checkedCreate('LoginTermsUrl', json, ($checkedConvert) {
      final val = LoginTermsUrl(
        url: $checkedConvert('url', (v) => v as String? ?? ''),
        language: $checkedConvert('language', (v) => v as String? ?? ''),
        excerpt: $checkedConvert('excerpt', (v) => v as bool? ?? false),
      );
      return val;
    });

Map<String, dynamic> _$LoginTermsUrlToJson(LoginTermsUrl instance) =>
    <String, dynamic>{
      'url': instance.url,
      'language': instance.language,
      'excerpt': instance.excerpt,
    };
