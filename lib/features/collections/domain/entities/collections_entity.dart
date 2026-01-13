import 'package:equatable/equatable.dart';

class CollectionsEntity extends Equatable {
  final String id;

  const CollectionsEntity({required this.id});

  @override
  List<Object?> get props => [id];
}
