import 'package:edubadges/shared/data/models/institution_model.dart';
import 'package:edubadges/shared/domain/entities/faculty_entity.dart';
import 'package:edubadges/shared/domain/entities/institution_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'faculty_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class FacultyModel extends FacultyEntity {
  const FacultyModel({
    super.nameDutch,
    super.nameEnglish,
    super.imageDutch,
    super.imageEnglish,
    @JsonKey(defaultValue: false) super.onBehalfOf,
    super.onBehalfOfDisplayName,
    super.onBehalfOfUrl,
    @JsonKey(fromJson: _institutionFromJson, toJson: _institutionToJson)
    super.institution,
  });

  factory FacultyModel.fromJson(Map<String, dynamic> json) =>
      _$FacultyModelFromJson(json);

  Map<String, dynamic> toJson() => _$FacultyModelToJson(this);

  @override
  @JsonKey(fromJson: _institutionFromJson, toJson: _institutionToJson)
  InstitutionEntity? get institution => super.institution;

  static InstitutionEntity? _institutionFromJson(Map<String, dynamic>? json) =>
      json == null ? null : InstitutionModel.fromJson(json);

  static Map<String, dynamic>? _institutionToJson(
    InstitutionEntity? institution,
  ) => institution == null ? null : (institution as InstitutionModel).toJson();
}
