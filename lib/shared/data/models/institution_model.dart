import 'package:edubadges/shared/domain/entities/institution_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'institution_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
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

  factory InstitutionModel.fromJson(Map<String, dynamic> json) =>
      _$InstitutionModelFromJson(json);

  Map<String, dynamic> toJson() => _$InstitutionModelToJson(this);
}
