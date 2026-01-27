import 'package:edubadges/features/login/data/models/login_terms.dart';

class LoginTermsAgreement {
  final bool agreed;
  final int agreedVersion;
  final LoginTerms terms;

  LoginTermsAgreement({
    required this.agreed,
    required this.agreedVersion,
    required this.terms,
  });

  factory LoginTermsAgreement.fromJson(Map<String, dynamic> json) {
    return LoginTermsAgreement(
      agreed: json['agreed'] as bool? ?? false,
      agreedVersion: json['agreed_version'] as int? ?? 0,
      terms: LoginTerms.fromJson(json['terms'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'agreed': agreed,
    'agreed_version': agreedVersion,
    'terms': terms.toJson(),
  };
}