import 'package:edubadges/shared/domain/entities/badge_instance_entity.dart';
import 'package:equatable/equatable.dart';

class CollectionsEntity extends Equatable {
  final String id;
  final String entityId;
  final String name;
  final String? description;
  final List<String> badgeInstanceIds;
  final List<BadgeInstanceEntity>? badgeInstances;
  final bool public;

  const CollectionsEntity({
    required this.id,
    required this.entityId,
    required this.name,
    this.description,
    required this.badgeInstanceIds,
    this.badgeInstances,
    this.public = false,
  });

  CollectionsEntity copyWith({
    String? id,
    String? entityId,
    String? name,
    String? description,
    List<String>? badgeInstanceIds,
    List<BadgeInstanceEntity>? badgeInstances,
    bool? public,
  }) {
    return CollectionsEntity(
      id: id ?? this.id,
      entityId: entityId ?? this.entityId,
      name: name ?? this.name,
      description: description ?? this.description,
      badgeInstanceIds: badgeInstanceIds ?? this.badgeInstanceIds,
      badgeInstances: badgeInstances ?? this.badgeInstances,
      public: public ?? this.public,
    );
  }

  @override
  List<Object?> get props => [
    id,
    entityId,
    name,
    description,
    badgeInstanceIds,
    badgeInstances,
    public,
  ];
}
