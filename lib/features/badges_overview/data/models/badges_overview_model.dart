import 'package:edubadges/features/badges_overview/domain/entities/badges_overview_entity.dart';

class BadgesOverviewModel extends BadgesOverviewEntity {
  const BadgesOverviewModel({required super.id});

  factory BadgesOverviewModel.fromJson(Map<String, dynamic> json) {
    return BadgesOverviewModel(id: json['id'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}
