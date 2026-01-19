import 'package:edubadges/core/network/api_client.dart';
import 'package:edubadges/core/utils/logger.dart';

abstract class GeneralTermsDataSource {
  Future<String> getTermsUrl();
}

class GeneralTermsDataSourceImpl implements GeneralTermsDataSource {
  final ApiClient apiClient;

  GeneralTermsDataSourceImpl(this.apiClient);

  @override
  Future<String> getTermsUrl() async {
    try {
      final response = await apiClient.get('/accept-general-terms');
      logger.i('Get terms URL call completed with status code: ${response.statusCode}');

      if (response.statusCode == 200 && response.data != null) {
        // Assuming the response body contains the URL to the markdown file.
        final url = response.data.toString();
        logger.i('Received terms URL from API: $url');
        return url;
      } else {
        logger.w('Failed to get terms URL. Status: ${response.statusCode}');
        throw Exception('Failed to get terms URL');
      }
    } catch (e, s) {
      logger.e('Error getting terms URL', error: e, stackTrace: s);
      rethrow;
    }
  }
}
