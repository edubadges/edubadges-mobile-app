import 'dart:convert';

import 'package:dio/dio.dart';

/// Constants and helpers for API authentication error responses.
abstract final class AuthErrorConstants {
  static const String invalidCredentialsDetail =
      'Invalid authentication credentials.';

  static bool isInvalidAuthenticationCredentialsResponse(
    Response<dynamic>? response,
  ) {
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
    return detail == invalidCredentialsDetail;
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
