import 'package:edubadges/shared/data/models/faculty_model.dart';
import 'package:edubadges/shared/domain/entities/faculty_entity.dart';
import 'package:edubadges/shared/domain/entities/issuer_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'issuer_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class IssuerModel extends IssuerEntity {
  const IssuerModel({
    super.nameDutch,
    super.nameEnglish,
    super.imageDutch,
    super.imageEnglish,
    @JsonKey(fromJson: _facultyFromJson, toJson: _facultyToJson) super.faculty,
  });

  factory IssuerModel.fromJson(Map<String, dynamic> json) =>
      _$IssuerModelFromJson(json);

  Map<String, dynamic> toJson() => _$IssuerModelToJson(this);

  @override
  @JsonKey(fromJson: _facultyFromJson, toJson: _facultyToJson)
  FacultyEntity? get faculty => super.faculty;

  static FacultyEntity? _facultyFromJson(Map<String, dynamic>? json) =>
      json == null ? null : FacultyModel.fromJson(json);

  static Map<String, dynamic>? _facultyToJson(FacultyEntity? faculty) =>
      faculty == null ? null : (faculty as FacultyModel).toJson();
}
