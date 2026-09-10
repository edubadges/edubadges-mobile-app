import 'package:dio/dio.dart';
import 'package:edubadges/core/network/network_providers.dart';
import 'package:edubadges/core/utils/url_safety.dart';
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

/// Terms content is served from an organizer-configured URL, so the request is
/// pinned to https, bounded by timeouts, and read as plain text rather than
/// decoded as JSON. The content itself is sanitized at the render site.
const int _maxMarkdownChars = 2 * 1024 * 1024;

final markdownContentProvider =
    FutureProvider.autoDispose.family<String, String>((ref, url) async {
  if (urlScheme(url) != 'https') {
    throw Exception('Refusing to load terms content over a non-https URL.');
  }

  // A bare Dio: this endpoint is outside our API, so it must not receive the
  // auth headers the app's interceptors attach.
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      responseType: ResponseType.plain,
      followRedirects: true,
      maxRedirects: 3,
      headers: const <String, String>{'Accept': 'text/markdown, text/plain'},
    ),
  );
  final cancelToken = CancelToken();
  ref.onDispose(cancelToken.cancel);

  final response = await dio.get<String>(url, cancelToken: cancelToken);
  final content = response.data;
  if (response.statusCode != 200 || content == null) {
    throw Exception(
      'Failed to load terms content from $url. Status: ${response.statusCode}',
    );
  }
  if (content.length > _maxMarkdownChars) {
    throw Exception('Terms content from $url exceeds the size limit.');
  }
  return content;
});
