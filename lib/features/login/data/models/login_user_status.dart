import 'package:edubadges/features/login/data/models/login_terms_agreement.dart';

sealed class LoginUserAuthStatus {
  const LoginUserAuthStatus();
}

// Case 1: Redirect to eduID to link account
class LoginLinkAccountRequired extends LoginUserAuthStatus {
  const LoginLinkAccountRequired();

  factory LoginLinkAccountRequired.fromJson(Map<String, dynamic> _) =>
      const LoginLinkAccountRequired();

  Map<String, dynamic> toJson() => {'status': 'link-account'};
}

// Case 2: Redirect to eduID to revalidate name
class LoginRevalidateNameRequired extends LoginUserAuthStatus {
  const LoginRevalidateNameRequired();

  factory LoginRevalidateNameRequired.fromJson(Map<String, dynamic> _) =>
      const LoginRevalidateNameRequired();

  Map<String, dynamic> toJson() => {'status': 'revalidate-name'};
}

// Case 3: Show terms & conditions screen (terms_agreed == false)
class LoginTermsAgreementRequired extends LoginUserAuthStatus {
  final String email;
  final String firstName;
  final String lastName;
  final String validatedName;
  final List<String> schacHomes;
  final bool termsAgreed;
  final List<LoginTermsAgreement> termsAgreementSet;

  LoginTermsAgreementRequired({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.validatedName,
    required this.schacHomes,
    required this.termsAgreed,
    required this.termsAgreementSet,
  });

  factory LoginTermsAgreementRequired.fromJson(Map<String, dynamic> json) {
    return LoginTermsAgreementRequired(
      email: json['email'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      validatedName: json['validated_name'] as String? ?? '',
      schacHomes: (json['schac_homes'] as List<dynamic>?)?.cast<String>() ?? [],
      termsAgreed: json['terms_agreed'] as bool? ?? false,
      termsAgreementSet: (json['termsagreement_set'] as List<dynamic>?)
          ?.map((e) => LoginTermsAgreement.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
    'validated_name': validatedName,
    'schac_homes': schacHomes,
    'terms_agreed': termsAgreed,
    'termsagreement_set': termsAgreementSet.map((e) => e.toJson()).toList(),
  };
}

// Case 4: User is fully authenticated & terms accepted → proceed
class LoginUser extends LoginUserAuthStatus {
  final String email;
  final String firstName;
  final String lastName;
  final String validatedName;
  final List<String> schacHomes;
  final bool termsAgreed;
  final List<LoginTermsAgreement> termsAgreementSet;

  LoginUser({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.validatedName,
    required this.schacHomes,
    required this.termsAgreed,
    required this.termsAgreementSet,
  });

  factory LoginUser.fromJson(Map<String, dynamic> json) {
    return LoginUser(
      email: json['email'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      validatedName: json['validated_name'] as String? ?? '',
      schacHomes: (json['schac_homes'] as List<dynamic>?)?.cast<String>() ?? [],
      termsAgreed: json['terms_agreed'] as bool? ?? true,
      termsAgreementSet: (json['termsagreement_set'] as List<dynamic>?)
          ?.map((e) => LoginTermsAgreement.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
    'validated_name': validatedName,
    'schac_homes': schacHomes,
    'terms_agreed': termsAgreed,
    'termsagreement_set': termsAgreementSet.map((e) => e.toJson()).toList(),
  };
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