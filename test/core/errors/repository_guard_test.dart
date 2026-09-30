import 'package:edubadges/core/errors/failures.dart';
import 'package:edubadges/core/errors/repository_guard.dart';
import 'package:edubadges/core/network/errors/exceptions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('repositoryGuard', () {
    test(
      'maps ValidationException to ValidationFailure with apiErrorCode',
      () async {
        final result = await repositoryGuard<void>(() async {
          throw const ValidationException(
            message: 'Cannot withdraw',
            code: '206',
            apiErrorCode: 206,
          );
        });

        expect(result.isLeft(), isTrue);
        final failure = result.fold((f) => f, (_) => null);
        expect(failure, isA<ValidationFailure>());
        expect(failure?.apiErrorCode, 206);
        expect(failure?.code, '206');
      },
    );

    test('maps ServerException to ServerFailure', () async {
      final result = await repositoryGuard<void>(() async {
        throw const ServerException(message: 'Boom', statusCode: 500);
      });

      expect(result.fold((f) => f, (_) => null), isA<ServerFailure>());
    });
  });
}
