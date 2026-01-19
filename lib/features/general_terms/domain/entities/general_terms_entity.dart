import 'package:equatable/equatable.dart';

class GeneralTermsEntity extends Equatable {
  final String id;

  const GeneralTermsEntity({required this.id});

  @override
  List<Object?> get props => [id];
}
