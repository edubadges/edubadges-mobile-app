class CreateCollectionRequest {
  final String name;
  final String? description;
  final bool public;
  final List<int> badgeInstances;

  const CreateCollectionRequest({
    required this.name,
    this.description,
    required this.public,
    required this.badgeInstances,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null && description!.isNotEmpty) 'description': description,
      'public': public,
      'badge_instances': badgeInstances,
    };
  }
}
