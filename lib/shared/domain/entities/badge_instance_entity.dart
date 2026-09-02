import 'package:edubadges/shared/domain/entities/badge_class_entity.dart';
import 'package:edubadges/shared/domain/entities/badge_evidence_entity.dart';
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
  final DateTime? issuedOn;
  final String awardType;
  final bool revoked;
  final DateTime? expiresAt;
  final BadgeAcceptance acceptance;
  final bool public;
  final BadgeClassEntity badgeclass;
  final String? linkedinUrl;
  final String? gradeAchieved;
  final String? narrative;
  final bool includeGradeAchieved;
  final bool includeEvidence;
  final List<BadgeEvidenceEntity>? evidences;
  final String? eppn;
  final String? recipientEmail;
  final String? recipientFirstName;
  final String? recipientSurname;

  const BadgeInstanceEntity({
    required this.id,
    required this.createdAt,
    required this.entityId,
    this.issuedOn,
    required this.awardType,
    required this.revoked,
    this.expiresAt,
    required this.acceptance,
    required this.public,
    required this.badgeclass,
    this.linkedinUrl,
    this.gradeAchieved,
    this.narrative,
    this.includeGradeAchieved = false,
    this.includeEvidence = false,
    this.evidences,
    this.eppn,
    this.recipientEmail,
    this.recipientFirstName,
    this.recipientSurname,
  });

  bool get hasRecipientDetails =>
      _hasText(eppn) ||
      (_hasText(recipientEmail) &&
          _hasText(recipientFirstName) &&
          _hasText(recipientSurname));

  String? get recipientFullName {
    final parts = <String>[
      if (_hasText(recipientFirstName)) recipientFirstName!.trim(),
      if (_hasText(recipientSurname)) recipientSurname!.trim(),
    ];
    if (parts.isEmpty) {
      return null;
    }
    return parts.join(' ');
  }

  /// Direct awards without an EPPN were issued to a private e-mail address.
  bool get isAwardedToPrivateEmail =>
      !_hasText(eppn) && _hasText(recipientEmail);

  bool get shouldConfirmPrivateEmailName =>
      isAwardedToPrivateEmail && recipientFullName != null;

  static bool _hasText(String? value) =>
      value != null && value.trim().isNotEmpty;

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
    narrative,
    includeGradeAchieved,
    includeEvidence,
    evidences,
    eppn,
    recipientEmail,
    recipientFirstName,
    recipientSurname,
  ];
}
