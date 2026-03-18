import 'package:edubadges/features/badges_overview/domain/entities/direct_award_detail_entity.dart';

class DirectAwardDetailModel extends DirectAwardDetailEntity {
  const DirectAwardDetailModel({
    required super.id,
    required super.userHasAcceptedTerms,
  });

  factory DirectAwardDetailModel.fromJson(Map<String, dynamic> json) {
    return DirectAwardDetailModel(
      id: json['id'] as int,
      userHasAcceptedTerms: json['user_has_accepted_terms'] as bool? ?? false,
    );
  }
}
