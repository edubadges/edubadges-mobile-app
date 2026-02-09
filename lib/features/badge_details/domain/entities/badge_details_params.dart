import 'package:equatable/equatable.dart';

class BadgeDetailsParams extends Equatable {
  final String? badgeInstanceEntityId;
  final String? badgeClassEntityId;

  const BadgeDetailsParams({
    required this.badgeInstanceEntityId,
    required this.badgeClassEntityId,
  });

  @override
  List<Object?> get props => [badgeInstanceEntityId, badgeClassEntityId];
}