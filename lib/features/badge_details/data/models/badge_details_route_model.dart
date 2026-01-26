import 'package:edubadges/core/constants/route_path.dart';
import 'package:edubadges/features/badge_details/domain/enums/badge_details_route_from.dart';
class BadgeDetailsRouteModel {
  final String id;
  final BadgeDetailsRouteFrom from;

  const BadgeDetailsRouteModel({
    required this.id,
    this.from = BadgeDetailsRouteFrom.other,
  });

  factory BadgeDetailsRouteModel.fromJson(Map<String, dynamic> json) {
    return BadgeDetailsRouteModel(
      id: json['id'] as String,
      from: json['from'] as BadgeDetailsRouteFrom,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'from': from};
  }

  String buildRouteUrl() {
    final basePath = RoutePath.badge.replaceAll(':id', id);
    final uri = Uri.parse(basePath).replace(queryParameters: {'from': from.toValue()});
    return uri.toString();
  }
}
