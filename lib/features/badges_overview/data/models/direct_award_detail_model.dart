import 'package:edubadges/features/badges_overview/domain/entities/direct_award_detail_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'direct_award_detail_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class DirectAwardDetailModel extends DirectAwardDetailEntity {
  const DirectAwardDetailModel({
    required super.id,
    @JsonKey(defaultValue: false) required super.userHasAcceptedTerms,
  });

  factory DirectAwardDetailModel.fromJson(Map<String, dynamic> json) =>
      _$DirectAwardDetailModelFromJson(json);

  Map<String, dynamic> toJson() => _$DirectAwardDetailModelToJson(this);
}
