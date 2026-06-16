import 'dart:async';

import 'package:edubadges/core/analytics/piwik_pro_analytics.dart';
import 'package:flutter/material.dart';

class PiwikProRouteObserver extends NavigatorObserver {
  PiwikProRouteObserver(this._analytics);

  final PiwikProAnalytics _analytics;

  static final RegExp _uuidPattern = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _trackRoute(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) {
      _trackRoute(newRoute);
    }
  }

  void _trackRoute(Route<dynamic> route) {
    final String screenName = _resolveScreenName(route);
    unawaited(_analytics.trackScreen(screenName));
  }

  String _resolveScreenName(Route<dynamic> route) {
    final String? name = route.settings.name;
    if (name == null || name.isEmpty) {
      return 'unknown';
    }
    if (name.startsWith('/')) {
      return _normalizePath(name);
    }
    return name;
  }

  String _normalizePath(String path) {
    final List<String> segments = Uri.parse(path).pathSegments;
    if (segments.isEmpty) {
      return 'home';
    }
    return segments
        .map((String segment) => _looksLikeId(segment) ? ':id' : segment)
        .join('/');
  }

  bool _looksLikeId(String segment) {
    return _uuidPattern.hasMatch(segment) || segment.length > 24;
  }
}
