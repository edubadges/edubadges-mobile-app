import 'package:dio/dio.dart';
import 'package:edubadges/core/network/network_providers.dart';
import 'package:edubadges/features/general_terms/data/datasources/general_terms_datasource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final generalTermsDataSourceProvider = Provider<GeneralTermsDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return GeneralTermsDataSourceImpl(apiClient);
});

/// Cached markdown URL for general terms, set at login to avoid a profile fetch
/// from the Dio interceptor (circular dependency with [dioProvider]).
final generalTermsMarkdownUrlCacheProvider =
    NotifierProvider<GeneralTermsMarkdownUrlCache, String?>(
      GeneralTermsMarkdownUrlCache.new,
    );

class GeneralTermsMarkdownUrlCache extends Notifier<String?> {
  @override
  String? build() => null;

  void setUrl(String? url) {
    state = url;
  }
}

void cacheGeneralTermsMarkdownUrl(Ref ref, String url) {
  ref.read(generalTermsMarkdownUrlCacheProvider.notifier).setUrl(url);
}

void clearGeneralTermsMarkdownUrlCache(Ref ref) {
  ref.read(generalTermsMarkdownUrlCacheProvider.notifier).setUrl(null);
}

final markdownContentProvider =
    FutureProvider.autoDispose.family<String, String>((ref, url) async {
  final dio = Dio();
  final cancelToken = CancelToken();
  ref.onDispose(cancelToken.cancel);
  final response = await dio.get<String>(url, cancelToken: cancelToken);
  if (response.statusCode == 200 && response.data != null) {
    return response.data!;
  }
  throw Exception(
    'Failed to load terms content from $url. Status: ${response.statusCode}',
  );
});
