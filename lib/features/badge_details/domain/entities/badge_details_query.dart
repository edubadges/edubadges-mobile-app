import 'package:edubadges/features/badge_details/domain/enums/badge_details_scope.dart';
import 'package:equatable/equatable.dart';

/// Keys [badgeDetailsModelProvider]: which API to call and the path segment id.
class BadgeDetailsQuery extends Equatable {
  final BadgeDetailsScope scope;
  /// Claimed flow: badge **instance** entity id. Enrollment/public: **badge class** entity id.
  final String entityId;

  const BadgeDetailsQuery({
    required this.scope,
    required this.entityId,
  });

  @override
  List<Object?> get props => [scope, entityId];
}
