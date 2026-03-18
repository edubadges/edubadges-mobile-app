import 'package:equatable/equatable.dart';

class DirectAwardDetailEntity extends Equatable {
  final int id;
  final bool userHasAcceptedTerms;

  const DirectAwardDetailEntity({
    required this.id,
    required this.userHasAcceptedTerms,
  });

  @override
  List<Object?> get props => [id, userHasAcceptedTerms];
}
