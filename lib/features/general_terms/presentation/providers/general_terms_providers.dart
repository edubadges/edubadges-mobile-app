import 'package:dio/dio.dart';
import 'package:edubadges/core/network/network_providers.dart';
import 'package:edubadges/core/utils/logger.dart';
import 'package:edubadges/features/general_terms/data/datasources/general_terms_datasource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final generalTermsDataSourceProvider = Provider<GeneralTermsDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return GeneralTermsDataSourceImpl(apiClient);
});

final termsUrlProvider = FutureProvider<String>((ref) {
  final dataSource = ref.watch(generalTermsDataSourceProvider);
  return dataSource.getTermsUrl();
});

final markdownContentProvider = FutureProvider<String>((ref) async {
  final urlAsyncValue = ref.watch(termsUrlProvider);

  // When the async value is ready, fetch the content from the URL
  return urlAsyncValue.when(
    data: (url) async {
      logger.i('Fetching markdown content from URL: $url');
      // Use a new Dio instance for the external request to avoid sending auth headers.
      final dio = Dio();
      final response = await dio.get<String>(url);

      if (response.statusCode == 200 && response.data != null) {
        return response.data!;
      } else {
        throw Exception('Failed to load terms content from $url. Status: ${response.statusCode}');
      }
    },
    // While the URL is loading, we don't have content yet.
    loading: () => '', // Return empty string while loading
    // If fetching the URL fails, propagate the error.
    error: (err, stack) => throw err,
  );
});