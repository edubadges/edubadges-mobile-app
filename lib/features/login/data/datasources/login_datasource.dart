import 'package:edubadges/features/login/data/models/login_model.dart';

abstract class LoginDataSource {
  Future<List<LoginModel>> getLogins();
  Future<LoginModel> getLoginById(String id);
}
