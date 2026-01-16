import 'package:edubadges/shared/domain/entities/faculty_entity.dart';
import 'package:equatable/equatable.dart';

/// Issuer entity representing the issuer of a badge
class IssuerEntity extends Equatable {
  final String? nameDutch;
  final String? nameEnglish;
  final String? imageDutch;
  final String? imageEnglish;
  final FacultyEntity? faculty;

  const IssuerEntity({
    this.nameDutch,
    this.nameEnglish,
    this.imageDutch,
    this.imageEnglish,
    this.faculty,
  });

  @override
  List<Object?> get props => [
        nameDutch,
        nameEnglish,
        imageDutch,
        imageEnglish,
        faculty,
      ];
}
