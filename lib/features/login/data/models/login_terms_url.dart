import 'package:json_annotation/json_annotation.dart';

part 'login_terms_url.g.dart';

@JsonSerializable()
class LoginTermsUrl {
  @JsonKey(defaultValue: '')
  final String url;
  @JsonKey(defaultValue: '')
  final String language;
  @JsonKey(defaultValue: false)
  final bool excerpt;

  const LoginTermsUrl({
    required this.url,
    required this.language,
    required this.excerpt,
  });

  factory LoginTermsUrl.fromJson(Map<String, dynamic> json) =>
      _$LoginTermsUrlFromJson(json);

  Map<String, dynamic> toJson() => _$LoginTermsUrlToJson(this);
}
