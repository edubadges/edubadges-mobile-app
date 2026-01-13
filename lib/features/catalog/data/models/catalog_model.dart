import 'package:edubadges/features/catalog/domain/entities/catalog_entity.dart';

class CatalogModel extends CatalogEntity {
  const CatalogModel({required super.id});

  factory CatalogModel.fromJson(Map<String, dynamic> json) {
    return CatalogModel(id: json['id'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}
