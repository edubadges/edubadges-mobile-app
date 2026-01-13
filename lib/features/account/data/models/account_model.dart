import 'package:edubadges/features/account/domain/entities/account_entity.dart';

class AccountModel extends AccountEntity {
  const AccountModel({required super.id});

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(id: json['id'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}
