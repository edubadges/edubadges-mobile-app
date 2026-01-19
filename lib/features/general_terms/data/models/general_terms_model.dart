import 'package:edubadges/features/general_terms/domain/entities/general_terms_entity.dart';

class GeneralTermsModel extends GeneralTermsEntity {
  const GeneralTermsModel({required super.id});

  factory GeneralTermsModel.fromJson(Map<String, dynamic> json) {
    return GeneralTermsModel(id: json['id'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}
