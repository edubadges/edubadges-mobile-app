import 'package:edubadges/shared/data/models/faculty_model.dart';
import 'package:edubadges/shared/domain/entities/issuer_entity.dart';

class IssuerModel extends IssuerEntity {
  const IssuerModel({
    super.nameDutch,
    super.nameEnglish,
    super.imageDutch,
    super.imageEnglish,
    super.faculty,
  });

  factory IssuerModel.fromJson(Map<String, dynamic> json) {
    return IssuerModel(
      nameDutch: json['name_dutch'] as String?,
      nameEnglish: json['name_english'] as String?,
      imageDutch: json['image_dutch'] as String?,
      imageEnglish: json['image_english'] as String?,
      faculty: json['faculty'] != null
          ? FacultyModel.fromJson(json['faculty'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name_dutch': nameDutch,
      'name_english': nameEnglish,
      if (imageDutch != null) 'image_dutch': imageDutch,
      if (imageEnglish != null) 'image_english': imageEnglish,
      if (faculty != null) 'faculty': (faculty as FacultyModel).toJson(),
    };
  }
}
