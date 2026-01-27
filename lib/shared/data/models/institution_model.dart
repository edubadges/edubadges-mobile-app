import 'package:edubadges/shared/domain/entities/institution_entity.dart';

class InstitutionModel extends InstitutionEntity {
  const InstitutionModel({
    super.nameDutch,
    super.nameEnglish,
    super.imageDutch,
    super.imageEnglish,
    super.identifier,
    super.alternativeIdentifier,
    super.grondslagFormeel,
    super.grondslagInformeel,
  });

  factory InstitutionModel.fromJson(Map<String, dynamic> json) {
    return InstitutionModel(
      nameDutch: json['name_dutch'] as String?,
      nameEnglish: json['name_english'] as String?,
      imageDutch: json['image_dutch'] as String?,
      imageEnglish: json['image_english'] as String?,
      identifier: json['identifier'] as String?,
      alternativeIdentifier: json['alternative_identifier'] as String?,
      grondslagFormeel: json['grondslag_formeel'] as String?,
      grondslagInformeel: json['grondslag_informeel'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name_dutch': nameDutch,
      'name_english': nameEnglish,
      if (imageDutch != null) 'image_dutch': imageDutch,
      if (imageEnglish != null) 'image_english': imageEnglish,
      'identifier': identifier,
      if (alternativeIdentifier != null) 'alternative_identifier': alternativeIdentifier,
      if (grondslagFormeel != null) 'grondslag_formeel': grondslagFormeel,
      if (grondslagInformeel != null) 'grondslag_informeel': grondslagInformeel,
    };
  }
}
