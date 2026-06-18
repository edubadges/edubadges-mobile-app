import 'package:edubadges/features/account/data/models/profile_model.dart';
import 'package:edubadges/features/account/domain/entities/profile_entity.dart';
import 'package:edubadges/features/badges_overview/domain/entities/direct_award_detail_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'direct_award_detail_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class DirectAwardDetailModel extends DirectAwardDetailEntity {
  const DirectAwardDetailModel({
    required super.id,
    @JsonKey(defaultValue: false) required super.userHasAcceptedTerms,
    super.requiredTerms,
  });

  factory DirectAwardDetailModel.fromJson(Map<String, dynamic> json) =>
      _$DirectAwardDetailModelFromJson(json);

  Map<String, dynamic> toJson() => _$DirectAwardDetailModelToJson(this);

  @override
  @JsonKey(fromJson: _requiredTermsFromJson, toJson: _requiredTermsToJson)
  TermsEntity? get requiredTerms => super.requiredTerms;

  static TermsEntity? _requiredTermsFromJson(Object? value) {
    if (value is! Map<String, dynamic>) {
      return null;
    }
    return TermsModel.fromJson(value);
  }

  static Map<String, dynamic>? _requiredTermsToJson(TermsEntity? terms) =>
      terms == null ? null : (terms as TermsModel).toJson();
}
