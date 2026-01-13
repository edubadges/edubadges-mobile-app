import 'package:edubadges/features/login/domain/entities/login_entity.dart';

class LoginModel extends LoginEntity {
  const LoginModel({required super.id});

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(id: json['id'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}
