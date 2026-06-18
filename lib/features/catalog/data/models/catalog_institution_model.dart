import 'package:edubadges/features/catalog/domain/entities/catalog_institution.dart';
import 'package:json_annotation/json_annotation.dart';

part 'catalog_institution_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class CatalogInstitutionModel extends CatalogInstitution {
  const CatalogInstitutionModel({
    required super.entityId,
    super.nameDutch,
    super.nameEnglish,
  });

  factory CatalogInstitutionModel.fromJson(Map<String, dynamic> json) =>
      _$CatalogInstitutionModelFromJson(json);

  Map<String, dynamic> toJson() => _$CatalogInstitutionModelToJson(this);
}
