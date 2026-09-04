import 'package:edubadges/features/collections/domain/entities/collections_entity.dart';
import 'package:edubadges/shared/domain/entities/badge_instance_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'collections_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class CollectionsModel extends CollectionsEntity {
  const CollectionsModel({
    @JsonKey(fromJson: _stringFromDynamic) required super.id,
    @JsonKey(fromJson: _stringFromDynamic, includeToJson: false)
    required super.entityId,
    required super.name,
    super.description,
    @JsonKey(name: 'badge_instances', fromJson: _badgeInstanceIdsFromJson)
    required super.badgeInstanceIds,
    super.badgeInstances,
    @JsonKey(defaultValue: false) super.public = false,
  });

  factory CollectionsModel.fromJson(Map<String, dynamic> json) =>
      _$CollectionsModelFromJson(json);

  @override
  @JsonKey(fromJson: _stringFromDynamic)
  String get id => super.id;

  @override
  @JsonKey(fromJson: _stringFromDynamic, includeToJson: false)
  String get entityId => super.entityId;

  @override
  @JsonKey(name: 'badge_instances', fromJson: _badgeInstanceIdsFromJson)
  List<String> get badgeInstanceIds => super.badgeInstanceIds;

  @override
  CollectionsModel copyWith({
    String? id,
    String? entityId,
    String? name,
    String? description,
    List<String>? badgeInstanceIds,
    List<BadgeInstanceEntity>? badgeInstances,
    bool? public,
  }) {
    return CollectionsModel(
      id: id ?? this.id,
      entityId: entityId ?? this.entityId,
      name: name ?? this.name,
      description: description ?? this.description,
      badgeInstanceIds: badgeInstanceIds ?? this.badgeInstanceIds,
      badgeInstances: badgeInstances ?? this.badgeInstances,
      public: public ?? this.public,
    );
  }

  Map<String, dynamic> toJson() => _$CollectionsModelToJson(this);

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  List<BadgeInstanceEntity>? get badgeInstances => super.badgeInstances;

  static String _stringFromDynamic(dynamic value) {
    if (value == null) return '';
    if (value is int) return value.toString();
    return value as String;
  }

  static List<String> _badgeInstanceIdsFromJson(List<dynamic>? badgeIds) {
    final source = badgeIds ?? <dynamic>[];
    return source.map((item) {
      if (item is String) return item;
      if (item is int) return item.toString();
      if (item is Map<String, dynamic> && item.containsKey('entity_id')) {
        return _stringFromDynamic(item['entity_id']);
      }
      if (item is Map<String, dynamic> && item.containsKey('id')) {
        return _stringFromDynamic(item['id']);
      }
      throw FormatException('Invalid badge instance ID format: $item');
    }).toList();
  }
}
