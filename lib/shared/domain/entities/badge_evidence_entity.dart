import 'package:equatable/equatable.dart';

class BadgeEvidenceEntity extends Equatable {
  final String? evidenceUrl;
  final String? narrative;
  final String? name;
  final String? description;

  const BadgeEvidenceEntity({
    this.evidenceUrl,
    this.narrative,
    this.name,
    this.description,
  });

  @override
  List<Object?> get props => [
        evidenceUrl,
        narrative,
        name,
        description,
      ];
}
