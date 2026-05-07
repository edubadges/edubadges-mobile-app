// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_user_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginLinkAccountRequired _$LoginLinkAccountRequiredFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('LoginLinkAccountRequired', json, ($checkedConvert) {
  final val = LoginLinkAccountRequired(
    status: $checkedConvert('status', (v) => v as String? ?? 'link-account'),
  );
  return val;
});

Map<String, dynamic> _$LoginLinkAccountRequiredToJson(
  LoginLinkAccountRequired instance,
) => <String, dynamic>{'status': instance.status};

LoginRevalidateNameRequired _$LoginRevalidateNameRequiredFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('LoginRevalidateNameRequired', json, ($checkedConvert) {
  final val = LoginRevalidateNameRequired(
    status: $checkedConvert('status', (v) => v as String? ?? 'revalidate-name'),
  );
  return val;
});

Map<String, dynamic> _$LoginRevalidateNameRequiredToJson(
  LoginRevalidateNameRequired instance,
) => <String, dynamic>{'status': instance.status};

LoginTermsAgreementRequired _$LoginTermsAgreementRequiredFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'LoginTermsAgreementRequired',
  json,
  ($checkedConvert) {
    final val = LoginTermsAgreementRequired(
      email: $checkedConvert('email', (v) => v as String? ?? ''),
      firstName: $checkedConvert('first_name', (v) => v as String? ?? ''),
      lastName: $checkedConvert('last_name', (v) => v as String? ?? ''),
      validatedName: $checkedConvert(
        'validated_name',
        (v) => v as String? ?? '',
      ),
      schacHomes: $checkedConvert(
        'schac_homes',
        (v) => (v as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      ),
      termsAgreed: $checkedConvert('terms_agreed', (v) => v as bool? ?? false),
      termsAgreementSet: $checkedConvert(
        'terms_agreement_set',
        (v) =>
            (v as List<dynamic>?)
                ?.map(
                  (e) =>
                      LoginTermsAgreement.fromJson(e as Map<String, dynamic>),
                )
                .toList() ??
            [],
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'firstName': 'first_name',
    'lastName': 'last_name',
    'validatedName': 'validated_name',
    'schacHomes': 'schac_homes',
    'termsAgreed': 'terms_agreed',
    'termsAgreementSet': 'terms_agreement_set',
  },
);

Map<String, dynamic> _$LoginTermsAgreementRequiredToJson(
  LoginTermsAgreementRequired instance,
) => <String, dynamic>{
  'email': instance.email,
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'validated_name': instance.validatedName,
  'schac_homes': instance.schacHomes,
  'terms_agreed': instance.termsAgreed,
  'terms_agreement_set': instance.termsAgreementSet
      .map((e) => e.toJson())
      .toList(),
};

LoginUser _$LoginUserFromJson(Map<String, dynamic> json) => $checkedCreate(
  'LoginUser',
  json,
  ($checkedConvert) {
    final val = LoginUser(
      email: $checkedConvert('email', (v) => v as String? ?? ''),
      firstName: $checkedConvert('first_name', (v) => v as String? ?? ''),
      lastName: $checkedConvert('last_name', (v) => v as String? ?? ''),
      validatedName: $checkedConvert(
        'validated_name',
        (v) => v as String? ?? '',
      ),
      schacHomes: $checkedConvert(
        'schac_homes',
        (v) => (v as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      ),
      termsAgreed: $checkedConvert('terms_agreed', (v) => v as bool? ?? true),
      termsAgreementSet: $checkedConvert(
        'terms_agreement_set',
        (v) =>
            (v as List<dynamic>?)
                ?.map(
                  (e) =>
                      LoginTermsAgreement.fromJson(e as Map<String, dynamic>),
                )
                .toList() ??
            [],
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'firstName': 'first_name',
    'lastName': 'last_name',
    'validatedName': 'validated_name',
    'schacHomes': 'schac_homes',
    'termsAgreed': 'terms_agreed',
    'termsAgreementSet': 'terms_agreement_set',
  },
);

Map<String, dynamic> _$LoginUserToJson(LoginUser instance) => <String, dynamic>{
  'email': instance.email,
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'validated_name': instance.validatedName,
  'schac_homes': instance.schacHomes,
  'terms_agreed': instance.termsAgreed,
  'terms_agreement_set': instance.termsAgreementSet
      .map((e) => e.toJson())
      .toList(),
};
