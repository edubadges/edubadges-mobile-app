import 'package:edubadges/shared/data/models/institution_model.dart';
import 'package:edubadges/shared/domain/entities/faculty_entity.dart';

class FacultyModel extends FacultyEntity {
  const FacultyModel({
    super.nameDutch,
    super.nameEnglish,
    super.imageDutch,
    super.imageEnglish,
    super.onBehalfOf,
    super.onBehalfOfDisplayName,
    super.onBehalfOfUrl,
    super.institution,
  });

  factory FacultyModel.fromJson(Map<String, dynamic> json) {
    return FacultyModel(
      nameDutch: json['name_dutch'] as String?,
      nameEnglish: json['name_english'] as String?,
      imageDutch: json['image_dutch'] as String?,
      imageEnglish: json['image_english'] as String?,
      onBehalfOf: json['on_behalf_of'] as bool? ?? false,
      onBehalfOfDisplayName: json['on_behalf_of_display_name'] as String?,
      onBehalfOfUrl: json['on_behalf_of_url'] as String?,
      institution: json['institution'] != null
          ? InstitutionModel.fromJson(json['institution'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name_dutch': nameDutch,
      'name_english': nameEnglish,
      if (imageDutch != null) 'image_dutch': imageDutch,
      if (imageEnglish != null) 'image_english': imageEnglish,
      'on_behalf_of': onBehalfOf,
      if (onBehalfOfDisplayName != null) 'on_behalf_of_display_name': onBehalfOfDisplayName,
      if (onBehalfOfUrl != null) 'on_behalf_of_url': onBehalfOfUrl,
      if (institution != null) 'institution': (institution as InstitutionModel).toJson(),
    };
  }
}
