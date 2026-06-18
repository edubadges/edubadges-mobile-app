import 'package:edubadges/shared/data/models/badge_class_model.dart';
import 'package:edubadges/shared/data/models/badge_instance_model.dart';

class BadgeDetailsModel {
  final BadgeInstanceModel? badgeInstance;
  final BadgeClassModel badgeClass;
  final bool requested;

  const BadgeDetailsModel({
    required this.badgeInstance,
    required this.badgeClass,
    required this.requested,
  });
}
