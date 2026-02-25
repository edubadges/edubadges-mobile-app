import 'package:edubadges/core/network/api_client.dart';
import 'package:edubadges/features/account/data/datasources/account_datasource.dart';
import 'package:edubadges/features/account/data/models/profile_model.dart';

class AccountRemoteDataSourceImpl implements AccountDataSource {
  final ApiClient apiClient;

  AccountRemoteDataSourceImpl(this.apiClient);

  @override
  Future<ProfileModel> getProfile() async {
    final response = await apiClient.get('/profile');
    return ProfileModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<bool> deleteProfile() async {
    final response = await apiClient.delete('/profile');
    return response.statusCode == 204;
  }

  @override
  Future<void> rejectTerms(String entityId) async {
    await apiClient.patch<void>(
      '/terms-agreements/$entityId',
      data: {'agreed': false},
    );
  }
}
