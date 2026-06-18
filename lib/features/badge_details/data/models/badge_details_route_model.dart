import 'package:edubadges/features/badge_details/domain/enums/badge_details_scope.dart';
import 'package:json_annotation/json_annotation.dart';

part 'badge_details_route_model.g.dart';

@JsonSerializable()
class BadgeDetailsRouteModel {
  final String id;
  @JsonKey(fromJson: _scopeFromJson, toJson: _scopeToJson)
  final BadgeDetailsScope scope;
  @JsonKey(defaultValue: false)
  final bool showClaimedGallery;

  const BadgeDetailsRouteModel({
    required this.id,
    required this.scope,
    this.showClaimedGallery = false,
  });

  factory BadgeDetailsRouteModel.fromJson(Map<String, dynamic> json) =>
      _$BadgeDetailsRouteModelFromJson(json);

  Map<String, dynamic> toJson() => _$BadgeDetailsRouteModelToJson(this);

  static BadgeDetailsScope _scopeFromJson(String scope) =>
      BadgeDetailsScope.values.byName(scope);

  static String _scopeToJson(BadgeDetailsScope scope) => scope.name;
}
