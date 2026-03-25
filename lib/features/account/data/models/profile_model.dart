import 'package:edubadges/features/account/domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.entityId,
    required super.marketingOptIn,
    super.institution,
    required super.isSuperuser,
    required super.termsAgreed,
    required super.termsagreementSet,
    required super.dateJoined,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      entityId: json['entity_id'] as String? ?? '',
      marketingOptIn: json['marketing_opt_in'] as bool? ?? false,
      institution: json['institution'] as String?,
      isSuperuser: json['is_superuser'] as bool? ?? false,
      termsAgreed: json['terms_agreed'] as bool? ?? false,
      termsagreementSet: (json['termsagreement_set'] as List<dynamic>?)
          ?.map((e) => TermsAgreementModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      dateJoined: DateTime.parse(json['date_joined'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'entity_id': entityId,
      'marketing_opt_in': marketingOptIn,
      'institution': institution,
      'is_superuser': isSuperuser,
      'terms_agreed': termsAgreed,
      'termsagreement_set': termsagreementSet
          .map((e) => (e as TermsAgreementModel).toJson())
          .toList(),
      'date_joined': dateJoined.toIso8601String(),
    };
  }
}

class TermsAgreementModel extends TermsAgreementEntity {
  const TermsAgreementModel({
    required super.entityId,
    required super.agreed,
    required super.agreedVersion,
    super.agreedAt,
    required super.terms,
  });

  factory TermsAgreementModel.fromJson(Map<String, dynamic> json) {
    return TermsAgreementModel(
      entityId: json['entity_id'] as String? ?? '',
      agreed: json['agreed'] as bool? ?? false,
      agreedVersion: json['agreed_version'] as int? ?? 0,
      agreedAt: json['agreed_at'] != null 
          ? DateTime.parse(json['agreed_at'] as String)
          : null,
      terms: TermsModel.fromJson(json['terms'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'entity_id': entityId,
      'agreed': agreed,
      'agreed_version': agreedVersion,
      'agreed_at': agreedAt?.toIso8601String(),
      'terms': (terms as TermsModel).toJson(),
    };
  }
}

class TermsModel extends TermsEntity {
  const TermsModel({
    required super.entityId,
    required super.termsType,
    super.institution,
    required super.termsUrls,
  });

  factory TermsModel.fromJson(Map<String, dynamic> json) {
    return TermsModel(
      entityId: json['entity_id'] as String? ?? '',
      termsType: json['terms_type'] as String? ?? '',
      institution: json['institution'] != null
          ? InstitutionModel.fromJson(json['institution'] as Map<String, dynamic>)
          : null,
      termsUrls: (json['terms_urls'] as List<dynamic>?)
          ?.map((e) => TermsUrlModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'entity_id': entityId,
      'terms_type': termsType,
      'institution': institution != null
          ? (institution as InstitutionModel).toJson()
          : null,
      'terms_urls': termsUrls
          .map((e) => (e as TermsUrlModel).toJson())
          .toList(),
    };
  }
}

class InstitutionModel extends InstitutionEntity {
  const InstitutionModel({
    required super.nameDutch,
    required super.nameEnglish,
    required super.imageDutch,
    required super.imageEnglish,
    required super.identifier,
    required super.alternativeIdentifier,
    required super.legalBasisFormal,
    required super.legalBasisInformal,
  });

  factory InstitutionModel.fromJson(Map<String, dynamic> json) {
    return InstitutionModel(
      nameDutch: json['name_dutch'] as String? ?? '',
      nameEnglish: json['name_english'] as String? ?? '',
      imageDutch: json['image_dutch'] as String? ?? '',
      imageEnglish: json['image_english'] as String? ?? '',
      identifier: json['identifier'] as String? ?? '',
      alternativeIdentifier: json['alternative_identifier'] as String? ?? '',
      legalBasisFormal: json['grondslag_formeel'] as String? ?? '',
      legalBasisInformal: json['grondslag_informeel'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name_dutch': nameDutch,
      'name_english': nameEnglish,
      'image_dutch': imageDutch,
      'image_english': imageEnglish,
      'identifier': identifier,
      'alternative_identifier': alternativeIdentifier,
      'grondslag_formeel': legalBasisFormal,
      'grondslag_informeel': legalBasisInformal,
    };
  }
}

class TermsUrlModel extends TermsUrlEntity {
  const TermsUrlModel({
    required super.url,
    required super.language,
    required super.excerpt,
  });

  factory TermsUrlModel.fromJson(Map<String, dynamic> json) {
    return TermsUrlModel(
      url: json['url'] as String? ?? '',
      language: json['language'] as String? ?? '',
      excerpt: json['excerpt'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'language': language,
      'excerpt': excerpt,
    };
  }
}



