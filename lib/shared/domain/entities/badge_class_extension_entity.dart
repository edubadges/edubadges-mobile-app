import 'package:equatable/equatable.dart';

class BadgeClassExtensionEntity extends Equatable {
  final String name;
  final dynamic value;

  const BadgeClassExtensionEntity({
    required this.name,
    required this.value,
  });

  @override
  List<Object?> get props => [name, value];
}
