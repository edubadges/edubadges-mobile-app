import 'package:edubadges/features/badge_details/domain/enums/badge_details_scope.dart';

class BadgeDetailsRouteModel {
  final String id;
  final BadgeDetailsScope scope;
  final bool showClaimedGallery;

  const BadgeDetailsRouteModel({
    required this.id,
    required this.scope,
    this.showClaimedGallery = false,
  });

  factory BadgeDetailsRouteModel.fromJson(Map<String, dynamic> json) {
    return BadgeDetailsRouteModel(
      id: json['id'] as String,
      scope: BadgeDetailsScope.values.byName(json['scope'] as String),
      showClaimedGallery: json['showClaimedGallery'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scope': scope.name,
      'showClaimedGallery': showClaimedGallery,
    };
  }
}
