class CollectionRouteModel {
  final String id;
  final String title;
  final String? description;

  const CollectionRouteModel({
    required this.id,
    required this.title,
    this.description,
  });

  factory CollectionRouteModel.fromJson(Map<String, dynamic> json) {
    return CollectionRouteModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      if (description != null) 'description': description,
    };
  }
}
