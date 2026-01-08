import 'package:equatable/equatable.dart';

class AccountEntity extends Equatable {
  final String id;

  const AccountEntity({required this.id});

  @override
  List<Object?> get props => [id];
}
