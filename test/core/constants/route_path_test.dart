import 'package:edubadges/core/constants/route_path.dart';
import 'package:flutter_test/flutter_test.dart';

String? _redirectForAnonymousVisitor(String path) =>
    RoutePath.redirectForAnonymousVisitor(path);

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

    test('public badge pages and the login route do not redirect', () {
      expect(_redirectForAnonymousVisitor(RoutePath.login), isNull);
      expect(_redirectForAnonymousVisitor('/public/abc'), isNull);
      expect(_redirectForAnonymousVisitor('/enrollment/abc'), isNull);
      expect(
        _redirectForAnonymousVisitor('/public/abc/quality-assurance'),
        isNull,
      );
    });

    test('the backpack itself sends a logged-out visitor to login', () {
      expect(_redirectForAnonymousVisitor(RoutePath.main), RoutePath.login);
      expect(_redirectForAnonymousVisitor('/details/abc'), RoutePath.login);
      expect(_redirectForAnonymousVisitor('/collection/abc'), RoutePath.login);
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
