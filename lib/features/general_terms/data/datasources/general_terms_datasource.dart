import 'package:edubadges/core/network/api_client.dart';
import 'package:edubadges/core/utils/logger.dart';

abstract class GeneralTermsDataSource {
  Future<String> acceptTermsUrl();
}

class GeneralTermsDataSourceImpl implements GeneralTermsDataSource {
  final ApiClient apiClient;

  GeneralTermsDataSourceImpl(this.apiClient);

  @override
  Future<String> acceptTermsUrl() async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>('/accept-general-terms');

      if (response.statusCode == 200 && response.data != null) {
        final url = response.data.toString();
        return url;
      } else {
        throw Exception('Failed to get terms URL');
      }
    } catch (e, s) {
      logger.e('Error getting terms URL', error: e, stackTrace: s);
      rethrow;
    }
  }
}
