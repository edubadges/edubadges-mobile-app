import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Why the web backpack must not start the eduID login on its own.
///
/// Set when an automatic login would be wrong, and cleared again when the user
/// clicks the login button.
enum AutoLoginSuppression {
  /// The user logged out in this tab. Sending them straight back to eduID
  /// would undo the logout.
  loggedOut,

  /// The last login was cancelled or failed. Starting a new one automatically
  /// would loop.
  loginFailed,
}

/// What the login route shows.
enum LoginEntryMode {
  /// The landing page with its login button.
  landing,

  /// The landing page with a message that the last login did not succeed.
  landingWithError,

  /// Only a loading indicator: authentication is still resolving, the eduID
  /// redirect is under way, or the router is about to leave the login route.
  loading,

  /// Start the eduID login right away, without showing the landing page.
  startLogin,
}

/// Decides what a visitor of the login route gets to see.
///
/// Every protected route sends a logged-out visitor to the login route, and
/// public routes never do, so this only runs for visitors that need to log in.
///
/// On web a logged-out visitor goes straight to eduID
/// ([LoginEntryMode.startLogin]), unless [suppression] says that would be
/// wrong; then the landing page is the fallback. The mobile app shows the
/// landing page to a logged-out visitor.
///
/// A signed-in user only sees a loader: the router leaves the login route as
/// soon as it knows where to go next. If the login status could not be
/// loaded ([loginStatusFailed]), the router stays here and the user gets the
/// error with a button to try again.
LoginEntryMode resolveLoginEntryMode({
  required bool autoLoginSupported,
  required AsyncValue<bool> auth,
  required AutoLoginSuppression? suppression,
  bool loginStatusFailed = false,
}) {
  // Signed in: the router is about to leave the login route, on mobile too,
  // once it knows where to go next.
  if (auth.asData?.value ?? false) {
    return loginStatusFailed
        ? LoginEntryMode.landingWithError
        : LoginEntryMode.loading;
  }
  if (!autoLoginSupported) {
    return LoginEntryMode.landing;
  }
  // The login could not even leave the app (it failed before the redirect).
  if (auth.hasError && !auth.isLoading) {
    return LoginEntryMode.landingWithError;
  }
  switch (suppression) {
    case AutoLoginSuppression.loginFailed:
      return LoginEntryMode.landingWithError;
    case AutoLoginSuppression.loggedOut:
      return LoginEntryMode.landing;
    case null:
      return auth.isLoading
          ? LoginEntryMode.loading
          : LoginEntryMode.startLogin;
  }
}
