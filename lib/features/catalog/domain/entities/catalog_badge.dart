import 'package:edubadges/shared/domain/enums/badge_class_type.dart';
import 'package:equatable/equatable.dart';

class CatalogBadge extends Equatable {
  final DateTime createdAt;
  final String name;
  final String? image;
  final bool archived;
  final String entityId;
  final bool isPrivate;
  final bool isMicroCredentials;
  final BadgeClassType badgeClassType;
  
  final String? issuerNameEnglish;
  final String? issuerNameDutch;
  final String issuerEntityId;
  final String? issuerImageDutch;
  final String? issuerImageEnglish;
  
  final String? facultyNameEnglish;
  final String? facultyNameDutch;
  final String facultyEntityId;
  final String? facultyImageDutch;
  final String? facultyImageEnglish;
  final bool facultyOnBehalfOf;
  final String? facultyType;
  
  final String? institutionNameEnglish;
  final String? institutionNameDutch;
  final String institutionEntityId;
  final String? institutionImageDutch;
  final String? institutionImageEnglish;
  final String? institutionType;

  const CatalogBadge({
    required this.createdAt,
    required this.name,
    this.image,
    required this.archived,
    required this.entityId,
    required this.isPrivate,
    required this.isMicroCredentials,
    required this.badgeClassType,
    this.issuerNameEnglish,
    this.issuerNameDutch,
    required this.issuerEntityId,
    this.issuerImageDutch,
    this.issuerImageEnglish,
    this.facultyNameEnglish,
    this.facultyNameDutch,
    required this.facultyEntityId,
    this.facultyImageDutch,
    this.facultyImageEnglish,
    required this.facultyOnBehalfOf,
    this.facultyType,
    this.institutionNameEnglish,
    this.institutionNameDutch,
    required this.institutionEntityId,
    this.institutionImageDutch,
    this.institutionImageEnglish,
    this.institutionType,
  });

  @override
  List<Object?> get props => [
        createdAt,
        name,
        image,
        archived,
        entityId,
        isPrivate,
        isMicroCredentials,
        badgeClassType,
        issuerNameEnglish,
        issuerNameDutch,
        issuerEntityId,
        issuerImageDutch,
        issuerImageEnglish,
        facultyNameEnglish,
        facultyNameDutch,
        facultyEntityId,
        facultyImageDutch,
        facultyImageEnglish,
        facultyOnBehalfOf,
        facultyType,
        institutionNameEnglish,
        institutionNameDutch,
        institutionEntityId,
        institutionImageDutch,
        institutionImageEnglish,
        institutionType,
      ];
}
