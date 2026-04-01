import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final externalContentDioProvider = Provider<Dio>((ref) {
  final dio = Dio();
  dio.options.connectTimeout = const Duration(seconds: 30);
  dio.options.receiveTimeout = const Duration(seconds: 30);
  dio.options.followRedirects = true;
  return dio;
});

final markdownFetcherProvider = FutureProvider.autoDispose.family<String, String>(
  (ref, url) async {
    // Use a clean Dio instance without API interceptors for external content (fixes some content loading issues)
    final dio = ref.read(externalContentDioProvider);
    
    try {
      final response = await dio.get<String>(
        url,
        options: Options(
          responseType: ResponseType.plain,
        ),
      );
      
      return response.data ?? '';
    } on DioException catch (e) {
      throw Exception('Failed to fetch markdown from $url: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error fetching markdown: $e');
    }
  },
);
