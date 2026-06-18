import 'package:edubadges/shared/domain/entities/badge_instance_entity.dart';
import 'package:equatable/equatable.dart';

class BadgesOverviewState extends Equatable {
  final List<BadgeInstanceEntity> claimedBadges;
  final List<BadgeInstanceEntity> unclaimedBadges;
  final List<BadgeInstanceEntity> requestedBadges;

  const BadgesOverviewState({
    required this.claimedBadges,
    required this.unclaimedBadges,
    required this.requestedBadges,
  });

  int get unclaimedCount => unclaimedBadges.length;

  @override
  List<Object?> get props => [claimedBadges, unclaimedBadges, requestedBadges];
}
