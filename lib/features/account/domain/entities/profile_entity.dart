import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String firstName;
  final String lastName;
  final String email;
  final String entityId;
  final bool marketingOptIn;
  final String? institution;
  final bool isSuperuser;

  const ProfileEntity({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.entityId,
    required this.marketingOptIn,
    this.institution,
    required this.isSuperuser,
  });

  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    email,
    entityId,
    marketingOptIn,
    institution,
    isSuperuser,
  ];
}
