import 'package:edubadges/features/collections/domain/entities/collections_entity.dart';

class CollectionsModel extends CollectionsEntity {
  const CollectionsModel({required super.id});

  factory CollectionsModel.fromJson(Map<String, dynamic> json) {
    return CollectionsModel(id: json['id'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}
