import 'package:edubadges/shared/domain/entities/badge_class_entity.dart';
import 'package:equatable/equatable.dart';

/// Badge instance entity representing an awarded badge
/// This is the top-level entity that contains badge instance information
/// and a nested badgeclass
class BadgeInstanceEntity extends Equatable {
  final int id;
  final DateTime createdAt;
  final String entityId;
  final DateTime issuedOn;
  final String awardType;
  final bool revoked;
  final DateTime? expiresAt;
  final String acceptance;
  final bool public;
  final BadgeClassEntity badgeclass;

  const BadgeInstanceEntity({
    required this.id,
    required this.createdAt,
    required this.entityId,
    required this.issuedOn,
    required this.awardType,
    required this.revoked,
    this.expiresAt,
    required this.acceptance,
    required this.public,
    required this.badgeclass,
  });

  @override
  List<Object?> get props => [
        id,
        createdAt,
        entityId,
        issuedOn,
        awardType,
        revoked,
        expiresAt,
        acceptance,
        public,
        badgeclass,
      ];
}
