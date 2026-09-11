import 'package:edubadges/core/constants/route_path.dart';
import 'package:flutter_test/flutter_test.dart';

/// Mirrors the guard in `routes.dart`, which sends an anonymous visitor to
/// [RoutePath.login] for every location that is not public.
String? _redirectForAnonymousVisitor(String path) {
  if (path == RoutePath.login || RoutePath.isPublicPath(path)) {
    return null;
  }
  return RoutePath.login;
}

void main() {
  group('isPublicPath', () {
    test('allows canonical anonymous badge routes', () {
      expect(RoutePath.isPublicPath('/public/badge-class-id'), isTrue);
      expect(RoutePath.isPublicPath('/enrollment/badge-class-id'), isTrue);
      expect(
        RoutePath.isPublicPath('/public/badge-class-id/quality-assurance'),
        isTrue,
      );
      expect(
        RoutePath.isPublicPath('/enrollment/badge-class-id/quality-assurance'),
        isTrue,
      );
    });

    test('allows legacy anonymous quality assurance routes', () {
      expect(
        RoutePath.isPublicPath('/quality-assurance/public/badge-class-id'),
        isTrue,
      );
      expect(
        RoutePath.isPublicPath('/quality-assurance/enrollment/badge-class-id'),
        isTrue,
      );
    });

    test('keeps authenticated routes private', () {
      expect(RoutePath.isPublicPath(RoutePath.collections), isFalse);
      expect(RoutePath.isPublicPath('/details/badge-instance-id'), isFalse);
      expect(
        RoutePath.isPublicPath('/quality-assurance/claimed/badge-instance-id'),
        isFalse,
      );
    });
  });

  group('anonymous navigation', () {
    test('legacy quality assurance URLs do not redirect to login', () {
      expect(
        _redirectForAnonymousVisitor('/quality-assurance/public/abc'),
        isNull,
      );
      expect(
        _redirectForAnonymousVisitor('/quality-assurance/enrollment/abc'),
        isNull,
      );
    });

    test('claimed badge URLs still redirect to login', () {
      expect(
        _redirectForAnonymousVisitor('/quality-assurance/claimed/abc'),
        RoutePath.login,
      );
      expect(
        _redirectForAnonymousVisitor(RoutePath.collections),
        RoutePath.login,
      );
    });
  });
}
