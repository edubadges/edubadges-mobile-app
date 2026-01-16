import 'package:equatable/equatable.dart';

/// Extension for badge class containing name-value pairs
class BadgeClassExtensionEntity extends Equatable {
  final String name;
  final String value;

  const BadgeClassExtensionEntity({
    required this.name,
    required this.value,
  });

  @override
  List<Object?> get props => [name, value];
}
