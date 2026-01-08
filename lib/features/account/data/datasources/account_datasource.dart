import 'package:edubadges/features/account/data/models/account_model.dart';

abstract class AccountDataSource {
  Future<List<AccountModel>> getAccounts();
  Future<AccountModel> getAccountById(String id);
}
