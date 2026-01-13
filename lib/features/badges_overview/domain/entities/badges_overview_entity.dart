import 'package:equatable/equatable.dart';

class BadgesOverviewEntity extends Equatable {
  final String id;

  const BadgesOverviewEntity({required this.id});

  @override
  List<Object?> get props => [id];
}
