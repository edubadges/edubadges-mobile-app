import 'package:flutter_appauth/flutter_appauth.dart';

/// Whether [error] means the stored grant can never succeed again.
///
/// Only these warrant clearing the session. Network failures, timeouts and
/// server errors are transient: clearing tokens for those logs the user out
/// every time a refresh happens to run while the connection is unavailable.
bool isPermanentAuthFailure(Object error) {
  if (error is FlutterAppAuthPlatformException) {
    final String? code = error.platformErrorDetails.error;
    return code == FlutterAppAuthOAuthError.invalidGrant ||
        code == FlutterAppAuthOAuthError.invalidClient ||
        code == FlutterAppAuthOAuthError.unauthorizedClient ||
        code == FlutterAppAuthOAuthError.invalidScope;
  }
  return false;
}
