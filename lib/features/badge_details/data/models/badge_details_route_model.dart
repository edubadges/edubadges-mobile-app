import 'package:edubadges/core/constants/route_path.dart';

class BadgeDetailsRouteModel {
  final String id;
  final String? from;

  const BadgeDetailsRouteModel({required this.id, this.from});

  factory BadgeDetailsRouteModel.fromJson(Map<String, dynamic> json) {
    return BadgeDetailsRouteModel(
      id: json['id'] as String,
      from: json['from'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, if (from != null) 'from': from};
  }

  String buildRouteUrl() {
    final basePath = RoutePath.badge.replaceAll(':id', id);
    final uri = Uri.parse(basePath).replace(
      queryParameters: {if (from != null && from!.isNotEmpty) 'from': from!},
    );
    return uri.toString();
  }
}
