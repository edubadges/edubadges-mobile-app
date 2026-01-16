import 'package:edubadges/shared/domain/entities/institution_entity.dart';
import 'package:equatable/equatable.dart';

/// Faculty entity representing a faculty within an institution
class FacultyEntity extends Equatable {
  final String? nameDutch;
  final String? nameEnglish;
  final String? imageDutch;
  final String? imageEnglish;
  final bool onBehalfOf;
  final String? onBehalfOfDisplayName;
  final String? onBehalfOfUrl;
  final InstitutionEntity? institution;

  const FacultyEntity({
    this.nameDutch,
    this.nameEnglish,
    this.imageDutch,
    this.imageEnglish,
    this.onBehalfOf = false,
    this.onBehalfOfDisplayName,
    this.onBehalfOfUrl,
    this.institution,
  });

  @override
  List<Object?> get props => [
        nameDutch,
        nameEnglish,
        imageDutch,
        imageEnglish,
        onBehalfOf,
        onBehalfOfDisplayName,
        onBehalfOfUrl,
        institution,
      ];
}
