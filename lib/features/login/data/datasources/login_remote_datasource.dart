import 'package:edubadges/core/network/api_client.dart';
import 'package:edubadges/core/utils/logger.dart';
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
      final response = await apiClient.get('/login');
      logger.i('Login API call completed with status code: ${response.statusCode}');

      if (response.statusCode == 200 && response.data != null) {
        final jsonBody = response.data as Map<String, dynamic>;
        final status = parseUserAuthStatus(jsonBody);
        logger.i('Parsed auth status is: ${status.runtimeType}');
        return status;
      } else {
        logger.w('Login API call failed. Status: ${response.statusCode}, Body: ${response.data}');
        throw Exception('Login API call failed');
      }
    } catch (e, s) {
      logger.e('Error during login API call', error: e, stackTrace: s);
      rethrow;
    }
  }
}
