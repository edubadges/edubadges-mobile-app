import 'package:edubadges/shared/data/models/badge_instance_model.dart';
import 'package:equatable/equatable.dart';

class BadgesOverviewState extends Equatable {
  final List<BadgeInstanceModel> claimedBadges;
  final List<BadgeInstanceModel> unclaimedBadges;
  final List<BadgeInstanceModel> requestedBadges;

  const BadgesOverviewState({
    required this.claimedBadges,
    required this.unclaimedBadges,
    required this.requestedBadges,
  });

  int get unclaimedCount => unclaimedBadges.length;

  @override
  List<Object?> get props => [claimedBadges, unclaimedBadges, requestedBadges];
}
