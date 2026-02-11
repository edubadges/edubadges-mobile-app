import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String firstName;
  final String lastName;
  final String email;
  final String entityId;
  final bool marketingOptIn;
  final String? institution;
  final bool isSuperuser;
  final bool termsAgreed;
  final List<TermsAgreementEntity> termsagreementSet;

  const ProfileEntity({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.entityId,
    required this.marketingOptIn,
    this.institution,
    required this.isSuperuser,
    required this.termsAgreed,
    required this.termsagreementSet,
  });

  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    email,
    entityId,
    marketingOptIn,
    institution,
    isSuperuser,
    termsAgreed,
    termsagreementSet,
  ];
}

class TermsAgreementEntity extends Equatable {
  final String entityId;
  final bool agreed;
  final int agreedVersion;
  final DateTime? agreedAt;
  final TermsEntity terms;

  const TermsAgreementEntity({
    required this.entityId,
    required this.agreed,
    required this.agreedVersion,
    this.agreedAt,
    required this.terms,
  });

  @override
  List<Object?> get props => [
    entityId,
    agreed,
    agreedVersion,
    agreedAt,
    terms,
  ];
}

class TermsEntity extends Equatable {
  final String entityId;
  final String termsType;
  final InstitutionEntity? institution;
  final List<TermsUrlEntity> termsUrls;

  const TermsEntity({
    required this.entityId,
    required this.termsType,
    this.institution,
    required this.termsUrls,
  });

  @override
  List<Object?> get props => [
    entityId,
    termsType,
    institution,
    termsUrls,
  ];
}

class InstitutionEntity extends Equatable {
  final String nameDutch;
  final String nameEnglish;
  final String imageDutch;
  final String imageEnglish;
  final String identifier;
  final String alternativeIdentifier;
  final String legalBasisFormal;
  final String legalBasisInformal;

  const InstitutionEntity({
    required this.nameDutch,
    required this.nameEnglish,
    required this.imageDutch,
    required this.imageEnglish,
    required this.identifier,
    required this.alternativeIdentifier,
    required this.legalBasisFormal,
    required this.legalBasisInformal,
  });

  @override
  List<Object?> get props => [
    nameDutch,
    nameEnglish,
    imageDutch,
    imageEnglish,
    identifier,
    alternativeIdentifier,
    legalBasisFormal,
    legalBasisInformal,
  ];
}

class TermsUrlEntity extends Equatable {
  final String url;
  final String language;
  final bool excerpt;

  const TermsUrlEntity({
    required this.url,
    required this.language,
    required this.excerpt,
  });

  @override
  List<Object?> get props => [
    url,
    language,
    excerpt,
  ];
}
