import 'package:edubadges/features/login/data/models/login_terms.dart';
import 'package:json_annotation/json_annotation.dart';

part 'login_terms_agreement.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class LoginTermsAgreement {
  @JsonKey(defaultValue: false)
  final bool agreed;
  @JsonKey(defaultValue: 0)
  final int agreedVersion;
  @JsonKey(fromJson: _termsFromJson)
  final LoginTerms terms;

  const LoginTermsAgreement({
    required this.agreed,
    required this.agreedVersion,
    required this.terms,
  });

  factory LoginTermsAgreement.fromJson(Map<String, dynamic> json) =>
      _$LoginTermsAgreementFromJson(json);

  Map<String, dynamic> toJson() => _$LoginTermsAgreementToJson(this);

  static LoginTerms _termsFromJson(Map<String, dynamic>? json) =>
      LoginTerms.fromJson(json ?? const {});
}
