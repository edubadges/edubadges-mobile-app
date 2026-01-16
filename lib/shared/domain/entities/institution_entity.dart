import 'package:equatable/equatable.dart';

/// Institution entity representing an educational institution
class InstitutionEntity extends Equatable {
  final String? nameDutch;
  final String? nameEnglish;
  final String? imageDutch;
  final String? imageEnglish;
  final String? identifier;
  final String? alternativeIdentifier;
  final String? grondslagFormeel;
  final String? grondslagInformeel;

  const InstitutionEntity({
    this.nameDutch,
    this.nameEnglish,
    this.imageDutch,
    this.imageEnglish,
    this.identifier,
    this.alternativeIdentifier,
    this.grondslagFormeel,
    this.grondslagInformeel,
  });

  @override
  List<Object?> get props => [
        nameDutch,
        nameEnglish,
        imageDutch,
        imageEnglish,
        identifier,
        alternativeIdentifier,
        grondslagFormeel,
        grondslagInformeel,
      ];
}
