import 'dart:convert';

import 'package:dio/dio.dart';

/// Constants and helpers for general terms acceptance API errors.
abstract final class GeneralTermsConstants {
  static const String notAcceptedDetail = 'General terms not accepted.';

  static const String termsOfServiceType = 'terms_of_service';

  /// When `true` on [RequestOptions.extra], skip redirect handling for this request.
  static const String skipRedirectExtraKey = 'skipGeneralTermsRedirect';

  static bool isNotAcceptedResponse(Response<dynamic>? response) {
    if (response == null) {
      return false;
    }
    final dataMap = _responseDataToMap(response.data);
    if (dataMap == null) {
      return false;
    }
    final detail = dataMap['detail'];
    if (detail is! String) {
      return false;
    }
    return detail == notAcceptedDetail;
  }

  static Map<String, dynamic>? _responseDataToMap(dynamic data) {
    if (data == null) {
      return null;
    }
    if (data is String) {
      try {
        final decoded = jsonDecode(data);
        return _responseDataToMap(decoded);
      } catch (_) {
        return null;
      }
    }
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      try {
        return Map<String, dynamic>.from(data);
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}
