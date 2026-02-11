import 'package:edubadges/features/catalog/domain/entities/catalog_institution.dart';

class CatalogInstitutionModel extends CatalogInstitution {
  const CatalogInstitutionModel({
    required super.entityId,
    super.nameDutch,
    super.nameEnglish,
  });

  factory CatalogInstitutionModel.fromJson(Map<String, dynamic> json) {
    return CatalogInstitutionModel(
      entityId: json['entity_id'] as String,
      nameDutch: json['name_dutch'] as String?,
      nameEnglish: json['name_english'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'entity_id': entityId,
      'name_dutch': nameDutch,
      'name_english': nameEnglish,
    };
  }
}
