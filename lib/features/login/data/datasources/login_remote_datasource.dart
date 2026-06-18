import 'package:edubadges/core/network/api_client.dart';
import 'package:edubadges/features/login/data/models/login_user_status.dart';

abstract class LoginRemoteDataSource {
  Future<LoginUserAuthStatus> login();
}

class LoginRemoteDataSourceImpl implements LoginRemoteDataSource {
  final ApiClient apiClient;

  LoginRemoteDataSourceImpl(this.apiClient);

  @override
  Future<LoginUserAuthStatus> login() async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>('/login');

      if (response.statusCode == 200 && response.data != null) {
        final jsonBody = response.data as Map<String, dynamic>;
        final status = parseUserAuthStatus(jsonBody);
        return status;
      } else {
        throw Exception('Login API call failed');
      }
    } catch (e, _) {
      rethrow;
    }
  }
}
