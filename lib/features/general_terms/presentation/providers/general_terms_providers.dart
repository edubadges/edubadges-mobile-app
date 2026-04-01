import 'package:dio/dio.dart';
import 'package:edubadges/core/network/network_providers.dart';
import 'package:edubadges/features/general_terms/data/datasources/general_terms_datasource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for the data source
final generalTermsDataSourceProvider = Provider<GeneralTermsDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return GeneralTermsDataSourceImpl(apiClient);
});

// Provider that accepts a URL and fetches the markdown content from it.
final markdownContentProvider = FutureProvider.autoDispose.family<String, String>((ref, url) async {
  final dio = Dio();
  final response = await dio.get<String>(url);

  if (response.statusCode == 200 && response.data != null) {
    return response.data!;
  } else {
    throw Exception('Failed to load terms content from $url. Status: ${response.statusCode}');
  }
});