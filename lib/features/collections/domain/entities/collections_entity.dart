import 'package:edubadges/shared/data/models/badge_instance_model.dart';
import 'package:equatable/equatable.dart';

class CollectionsEntity extends Equatable {
  final String id;
  final String entityId;
  final String name;
  final String? description;
  final List<int> badgeInstanceIds;
  final List<BadgeInstanceModel>? badgeInstances;
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
