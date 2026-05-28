import 'dart:async';

import 'package:dio/dio.dart';
import 'package:edubadges/features/general_terms/domain/general_terms_constants.dart';

/// Triggers navigation when the API returns a terms-not-accepted error.
class GeneralTermsInterceptor extends Interceptor {
  final Future<void> Function() onTermsRequired;

  GeneralTermsInterceptor({required this.onTermsRequired});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final skipRedirect =
        err.requestOptions.extra[GeneralTermsConstants.skipRedirectExtraKey] ==
        true;
    if (!skipRedirect &&
        GeneralTermsConstants.isNotAcceptedResponse(err.response)) {
      unawaited(
        onTermsRequired().catchError((error, stackTrace) {
          // Intentionally swallow/log to avoid unhandled async errors
        }),
      );
    }
    handler.next(err);
  }
}
