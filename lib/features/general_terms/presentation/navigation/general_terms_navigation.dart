import 'package:dio/dio.dart';
import 'package:edubadges/core/app_container.dart';
import 'package:edubadges/core/constants/route_path.dart';
import 'package:edubadges/core/utils/logger.dart';
import 'package:edubadges/features/general_terms/presentation/providers/general_terms_providers.dart';
import 'package:edubadges/features/general_terms/utils/general_terms_profile_utils.dart';

bool _isNavigatingToGeneralTerms = false;

/// Navigates to [RoutePath.generalTerms] when the user must accept general terms.
///
/// Uses [dio] and [appGoRouter] directly to avoid Riverpod circular dependencies
/// with [dioProvider] while a request is in flight.
Future<void> navigateToGeneralTermsIfNeeded(Dio dio) async {
  if (_isNavigatingToGeneralTerms) {
    return;
  }
  final router = appGoRouter;
  if (router == null) {
    return;
  }
  if (router.state.uri.path == RoutePath.generalTerms) {
    return;
  }
  _isNavigatingToGeneralTerms = true;
  try {
    await Future<void>.delayed(Duration.zero);
    if (router.state.uri.path == RoutePath.generalTerms) {
      return;
    }
    final termsUrl = await _resolveTermsUrl(dio);
    if (router.state.uri.path == RoutePath.generalTerms) {
      return;
    }
    router.go(RoutePath.generalTerms, extra: termsUrl);
  } catch (error, stackTrace) {
    logger.e(
      'Failed to navigate to general terms',
      error: error,
      stackTrace: stackTrace,
    );
  } finally {
    _isNavigatingToGeneralTerms = false;
  }
}

Future<String> _resolveTermsUrl(Dio dio) async {
  final container = appProviderContainer;
  if (container != null) {
    final cachedUrl = container.read(generalTermsMarkdownUrlCacheProvider);
    if (cachedUrl != null && cachedUrl.isNotEmpty) {
      return cachedUrl;
    }
  }
  final languageCode = _languageCodeFromDio(dio);
  final url = await fetchGeneralTermsMarkdownUrlFromProfile(dio, languageCode);
  container?.read(generalTermsMarkdownUrlCacheProvider.notifier).setUrl(url);
  return url;
}

String _languageCodeFromDio(Dio dio) {
  // Accept-Language is the one language header web sends as well.
  final header =
      dio.options.headers['Accept-Language'] ??
      dio.options.headers['x-language'];
  if (header is String && header.isNotEmpty) {
    final normalized = header.trim().toLowerCase();
    final firstToken = normalized.split(',').first;
    return firstToken.split(RegExp('[-_]')).first;
  }
  return 'en';
}
