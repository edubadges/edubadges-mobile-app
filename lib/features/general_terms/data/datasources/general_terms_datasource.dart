import 'package:edubadges/core/network/api_client.dart';
import 'package:edubadges/core/utils/logger.dart';

abstract class GeneralTermsDataSource {
  Future<void> acceptTerms();
}

class GeneralTermsDataSourceImpl implements GeneralTermsDataSource {
  final ApiClient apiClient;

  GeneralTermsDataSourceImpl(this.apiClient);

  @override
  Future<void> acceptTerms() async {
    try {
      final response = await apiClient.get<void>('/accept-general-terms');
      if (response.statusCode != 200) {
        throw Exception('Failed to accept general terms');
      }
    } catch (e, s) {
      logger.e('Error accepting general terms', error: e, stackTrace: s);
      rethrow;
    }
  }
}
