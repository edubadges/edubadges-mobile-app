import 'package:edubadges/features/account/data/models/profile_model.dart';

abstract class AccountDataSource {
  Future<ProfileModel> getProfile();
  Future<bool> deleteProfile();
}
