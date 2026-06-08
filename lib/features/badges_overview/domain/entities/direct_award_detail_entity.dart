import 'package:edubadges/features/account/domain/entities/profile_entity.dart';
import 'package:equatable/equatable.dart';

class DirectAwardDetailEntity extends Equatable {
  final int id;
  final bool userHasAcceptedTerms;
  final TermsEntity? requiredTerms;

  const DirectAwardDetailEntity({
    required this.id,
    required this.userHasAcceptedTerms,
    this.requiredTerms,
  });

  @override
  List<Object?> get props => [id, userHasAcceptedTerms, requiredTerms];
}
