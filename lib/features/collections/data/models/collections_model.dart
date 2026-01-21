import 'package:edubadges/features/collections/domain/entities/collections_entity.dart';
import 'package:edubadges/shared/data/models/badge_instance_model.dart';

class CollectionsModel extends CollectionsEntity {
  const CollectionsModel({
    required super.id,
    required super.name,
    super.description,
    required super.badgeInstanceIds,
    super.badgeInstances,
    super.public = false,
  });

  factory CollectionsModel.fromJson(Map<String, dynamic> json) {
    final badgeIds = json['badge_instances'] as List<dynamic>? ?? [];

    final badgeInstanceIds = badgeIds.map((item) {
      if (item is int) {
        return item;
      } else if (item is Map<String, dynamic> && item.containsKey('id')) {
        return item['id'] as int;
      } else {
        throw FormatException('Invalid badge instance ID format: $item');
      }
    }).toList();

    // Handle id as either int or String
    final idValue = json['id'];
    final id = idValue is int ? idValue.toString() : idValue as String;

    return CollectionsModel(
      id: id,
      name: json['name'] as String,
      description: json['description'] as String?,
      badgeInstanceIds: badgeInstanceIds,
      public: json['public'] as bool? ?? false,
    );
  }

  CollectionsModel copyWith({
    String? id,
    String? name,
    String? description,
    List<int>? badgeInstanceIds,
    List<BadgeInstanceModel>? badgeInstances,
    bool? public,
  }) {
    return CollectionsModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      badgeInstanceIds: badgeInstanceIds ?? this.badgeInstanceIds,
      badgeInstances: badgeInstances ?? this.badgeInstances,
      public: public ?? this.public,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      'badge_instances': badgeInstanceIds,
      'public': public,
    };
  }
}
