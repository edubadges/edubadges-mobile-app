import 'package:edubadges/shared/domain/entities/badge_class_extension_entity.dart';
import 'package:edubadges/shared/domain/entities/issuer_entity.dart';
import 'package:equatable/equatable.dart';

/// Badge class entity matching the API structure
/// Can contain different levels of detail depending on the endpoint
class BadgeClassEntity extends Equatable {
  final int id;
  final String name;
  final String entityId;
  final String? image;
  final String? description;
  final bool? formal;
  final String? participation;
  final String? assessmentType;
  final bool? assessmentIdVerified;
  final bool? assessmentSupervised;
  final String? qualityAssuranceName;
  final List<BadgeClassExtensionEntity>? badgeclassextensionSet;
  final IssuerEntity? issuer;

  const BadgeClassEntity({
    required this.id,
    required this.name,
    required this.entityId,
    this.image,
    this.description,
    this.formal,
    this.participation,
    this.assessmentType,
    this.assessmentIdVerified,
    this.assessmentSupervised,
    this.qualityAssuranceName,
    this.badgeclassextensionSet,
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
        badgeclassextensionSet,
        issuer,
      ];
}
