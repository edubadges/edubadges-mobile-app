import 'package:edubadges/features/login/data/models/login_terms_agreement.dart';
import 'package:json_annotation/json_annotation.dart';

part 'login_user_status.g.dart';

sealed class LoginUserAuthStatus {
  const LoginUserAuthStatus();
}

// Case 1: Redirect to eduID to link account
@JsonSerializable()
class LoginLinkAccountRequired extends LoginUserAuthStatus {
  @JsonKey(defaultValue: 'link-account')
  final String status;

  const LoginLinkAccountRequired({this.status = 'link-account'});

  factory LoginLinkAccountRequired.fromJson(Map<String, dynamic> json) =>
      _$LoginLinkAccountRequiredFromJson(json);

  Map<String, dynamic> toJson() => _$LoginLinkAccountRequiredToJson(this);
}

// Case 2: Redirect to eduID to revalidate name
@JsonSerializable()
class LoginRevalidateNameRequired extends LoginUserAuthStatus {
  @JsonKey(defaultValue: 'revalidate-name')
  final String status;

  const LoginRevalidateNameRequired({this.status = 'revalidate-name'});

  factory LoginRevalidateNameRequired.fromJson(Map<String, dynamic> json) =>
      _$LoginRevalidateNameRequiredFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRevalidateNameRequiredToJson(this);
}

// Case 3: Show terms & conditions screen (terms_agreed == false)
@JsonSerializable(fieldRename: FieldRename.snake)
class LoginTermsAgreementRequired extends LoginUserAuthStatus {
  @JsonKey(defaultValue: '')
  final String email;
  @JsonKey(defaultValue: '')
  final String firstName;
  @JsonKey(defaultValue: '')
  final String lastName;
  @JsonKey(defaultValue: '')
  final String validatedName;
  @JsonKey(defaultValue: <String>[])
  final List<String> schacHomes;
  @JsonKey(defaultValue: false)
  final bool termsAgreed;
  @JsonKey(defaultValue: <LoginTermsAgreement>[])
  final List<LoginTermsAgreement> termsAgreementSet;

  const LoginTermsAgreementRequired({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.validatedName,
    required this.schacHomes,
    required this.termsAgreed,
    required this.termsAgreementSet,
  });

  factory LoginTermsAgreementRequired.fromJson(Map<String, dynamic> json) =>
      _$LoginTermsAgreementRequiredFromJson(json);

  Map<String, dynamic> toJson() => _$LoginTermsAgreementRequiredToJson(this);
}

// Case 4: User is fully authenticated & terms accepted → proceed
@JsonSerializable(fieldRename: FieldRename.snake)
class LoginUser extends LoginUserAuthStatus {
  @JsonKey(defaultValue: '')
  final String email;
  @JsonKey(defaultValue: '')
  final String firstName;
  @JsonKey(defaultValue: '')
  final String lastName;
  @JsonKey(defaultValue: '')
  final String validatedName;
  @JsonKey(defaultValue: <String>[])
  final List<String> schacHomes;
  @JsonKey(defaultValue: true)
  final bool termsAgreed;
  @JsonKey(defaultValue: <LoginTermsAgreement>[])
  final List<LoginTermsAgreement> termsAgreementSet;

  const LoginUser({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.validatedName,
    required this.schacHomes,
    required this.termsAgreed,
    required this.termsAgreementSet,
  });

  factory LoginUser.fromJson(Map<String, dynamic> json) =>
      _$LoginUserFromJson(json);

  Map<String, dynamic> toJson() => _$LoginUserToJson(this);
}

LoginUserAuthStatus parseUserAuthStatus(Map<String, dynamic> json) {
  // The two redirect cases have a simple 'status' field
  final status = json['status'] as String?;
  if (status == 'link-account') {
    return const LoginLinkAccountRequired();
  }
  if (status == 'revalidate-name') {
    return const LoginRevalidateNameRequired();
  }

  // Otherwise it's one of the detailed user info objects
  final termsAgreed = json['terms_agreed'] as bool? ?? false;

  if (termsAgreed) {
    return LoginUser.fromJson(json);
  } else {
    return LoginTermsAgreementRequired.fromJson(json);
  }
}
