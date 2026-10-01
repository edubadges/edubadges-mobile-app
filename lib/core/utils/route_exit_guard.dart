import 'dart:async';

/// Lets the page shown on a `GoRoute` decide whether that route may be left.
///
/// `PopScope` only sees pops (app bar, Android back, iOS swipe). `GoRoute.onExit`
/// also runs when the route is left through `go()` or the browser's
/// back/forward buttons on web, but it lives on the route, away from the page
/// that knows about unsaved changes. The route owns one guard, forwards
/// `onExit` to [canExit] and hands the guard to its page, which [attach]es its
/// check while mounted.
class RouteExitGuard {
  Future<bool> Function()? _onExit;

  void attach(Future<bool> Function() onExit) {
    _onExit = onExit;
  }

  /// Only detaches when [onExit] is still the attached check, so a page that
  /// is disposed after its replacement attached does not remove the new one.
  void detach(Future<bool> Function() onExit) {
    if (_onExit == onExit) {
      _onExit = null;
    }
  }

  /// Whether the route may be left. Leaving is allowed when nothing is attached.
  FutureOr<bool> canExit() => _onExit?.call() ?? true;
}
