import 'package:collection/collection.dart';
import 'package:edubadges/features/account/domain/entities/profile_entity.dart';
import 'package:edubadges/shared/domain/entities/badge_alignment_entity.dart';
import 'package:edubadges/shared/domain/entities/badge_class_extension_entity.dart';
import 'package:edubadges/shared/domain/entities/issuer_entity.dart';
import 'package:edubadges/shared/domain/enums/assessment_type.dart';
import 'package:edubadges/shared/domain/enums/badge_class_type.dart';
import 'package:edubadges/shared/domain/enums/participation_type.dart';
import 'package:equatable/equatable.dart';

class BadgeClassEntity extends Equatable {
  final int id;
  final String name;
  final String entityId;
  final String image;
  final String? description;
  final bool? formal;
  final List<ParticipationType>? participation;
  final List<AssessmentType>? assessmentType;
  final bool? assessmentIdVerified;
  final bool? assessmentSupervised;
  final bool selfEnrollmentEnabled;
  final bool userMayEnroll;
  final bool userHasAcceptedTerms;
  final TermsEntity? requiredTerms;
  final bool? stackable;
  final String? qualityAssuranceName;
  final String? qualityAssuranceUrl;
  final String? qualityAssuranceDescription;
  final String? criteriaText;
  final bool eqfNlqfLevelVerified;

  final BadgeClassType badgeClassType;
  final List<BadgeClassExtensionEntity>? badgeclassextensionSet;
  final List<BadgeAlignmentEntity>? alignments;
  final IssuerEntity? issuer;

  const BadgeClassEntity({
    required this.id,
    required this.name,
    required this.entityId,
    required this.badgeClassType,
    required this.image,
    this.description,
    this.formal,
    this.participation,
    this.assessmentType,
    this.assessmentIdVerified,
    this.assessmentSupervised,
    this.selfEnrollmentEnabled = false,
    this.userMayEnroll = false,
    this.userHasAcceptedTerms = false,
    this.requiredTerms,
    this.stackable,
    this.qualityAssuranceName,
    this.qualityAssuranceUrl,
    this.qualityAssuranceDescription,
    this.criteriaText,
    this.eqfNlqfLevelVerified = false,
    this.badgeclassextensionSet,
    this.alignments,
    this.issuer,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    entityId,
    image,
    description,
    formal,
    participation,
    assessmentType,
    assessmentIdVerified,
    assessmentSupervised,
    qualityAssuranceName,
    qualityAssuranceUrl,
    qualityAssuranceDescription,
    selfEnrollmentEnabled,
    userMayEnroll,
    userHasAcceptedTerms,
    requiredTerms,
    stackable,
    criteriaText,
    eqfNlqfLevelVerified,
    badgeClassType,
    badgeclassextensionSet,
    alignments,
    issuer,
  ];
}

extension BadgeClassExtensions on BadgeClassEntity {
  T? getExtensionValue<T>(String extensionName) {
    final match = badgeclassextensionSet?.firstWhereOrNull(
      (element) => element.name == extensionName,
    );

    final value = match?.value;
    if (match?.value == null) return null;

    // Handle int to double conversion when T expects a double
    if (value is int && T.toString().contains('double')) {
      return value.toDouble() as T;
    }

    return value as T?;
  }
}
