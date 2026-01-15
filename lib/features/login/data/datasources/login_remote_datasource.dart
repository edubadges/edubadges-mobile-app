import 'package:aroma_networking/aroma_networking.dart';

abstract class LoginRemoteDataSource {
  Future<void> login();
}

class LoginRemoteDataSourceImpl implements LoginRemoteDataSource {
  final ApiClient apiClient;

  LoginRemoteDataSourceImpl(this.apiClient);

  @override
  Future<void> login() async {
    final response = await apiClient.get('/login');
    print(response);
  }
}
