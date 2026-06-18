import 'package:json_annotation/json_annotation.dart';

part 'collection_route_model.g.dart';

@JsonSerializable()
class CollectionRouteModel {
  final String id;
  final String title;
  final String? description;

  const CollectionRouteModel({
    required this.id,
    required this.title,
    this.description,
  });

  factory CollectionRouteModel.fromJson(Map<String, dynamic> json) =>
      _$CollectionRouteModelFromJson(json);

  Map<String, dynamic> toJson() => _$CollectionRouteModelToJson(this);
}
