// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_terms_agreement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginTermsAgreement _$LoginTermsAgreementFromJson(Map<String, dynamic> json) =>
    $checkedCreate('LoginTermsAgreement', json, ($checkedConvert) {
      final val = LoginTermsAgreement(
        agreed: $checkedConvert('agreed', (v) => v as bool? ?? false),
        agreedVersion: $checkedConvert(
          'agreed_version',
          (v) => (v as num?)?.toInt() ?? 0,
        ),
        terms: $checkedConvert(
          'terms',
          (v) => LoginTermsAgreement._termsFromJson(v as Map<String, dynamic>?),
        ),
      );
      return val;
    }, fieldKeyMap: const {'agreedVersion': 'agreed_version'});

Map<String, dynamic> _$LoginTermsAgreementToJson(
  LoginTermsAgreement instance,
) => <String, dynamic>{
  'agreed': instance.agreed,
  'agreed_version': instance.agreedVersion,
  'terms': instance.terms.toJson(),
};
