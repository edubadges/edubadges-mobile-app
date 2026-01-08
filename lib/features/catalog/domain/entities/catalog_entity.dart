import 'package:equatable/equatable.dart';

class CatalogEntity extends Equatable {
  final String id;

  const CatalogEntity({required this.id});

  @override
  List<Object?> get props => [id];
}
