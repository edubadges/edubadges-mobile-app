import 'package:json_annotation/json_annotation.dart';

part 'create_collection_request.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class CreateCollectionRequest {
  final String name;
  @JsonKey(toJson: _descriptionToJson)
  final String? description;
  final bool public;
  final List<String> badgeInstances;

  const CreateCollectionRequest({
    required this.name,
    this.description,
    required this.public,
    required this.badgeInstances,
  });

  factory CreateCollectionRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateCollectionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateCollectionRequestToJson(this);

  static String? _descriptionToJson(String? value) =>
      (value == null || value.isEmpty) ? null : value;
}
