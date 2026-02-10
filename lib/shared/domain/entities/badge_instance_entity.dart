import 'package:edubadges/shared/domain/entities/badge_class_entity.dart';
import 'package:equatable/equatable.dart';

enum BadgeAcceptance {
  unaccepted('Unaccepted'),
  accepted('Accepted'),
  rejected('Rejected');

  const BadgeAcceptance(this.value);
  final String value;

  static BadgeAcceptance fromString(String value) {
    return BadgeAcceptance.values.firstWhere(
      (e) => e.value == value,
      orElse: () => BadgeAcceptance.unaccepted,
    );
  }
}

class BadgeInstanceEntity extends Equatable {
  final int id;
  final DateTime createdAt;
  final String entityId;
  final DateTime issuedOn;
  final String awardType;
  final bool revoked;
  final DateTime? expiresAt;
  final BadgeAcceptance acceptance;
  final bool public;
  final BadgeClassEntity badgeclass;
  final String? linkedinUrl;
  final String? gradeAchieved;
  final bool includeGradeAchieved;
  final bool includeEvidence;

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
    this.linkedinUrl,
    this.gradeAchieved,
    this.includeGradeAchieved = false,
    this.includeEvidence = false,
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
    linkedinUrl,
    gradeAchieved,
    includeGradeAchieved,
    includeEvidence,
  ];
}
