import 'package:dartz/dartz.dart';
import 'package:edubadges/core/errors/failures.dart';
import 'package:edubadges/core/network/errors/exceptions.dart';
import 'package:edubadges/core/utils/logger.dart';

Future<Either<Failure, T>> repositoryGuard<T>(
  Future<T> Function() operation, {
  String logMessage = 'Repository request failed',
}) async {
  try {
    final result = await operation();
    return Right(result);
  } on AppException catch (e, stackTrace) {
    logger.e(logMessage, error: e, stackTrace: stackTrace);

    if (e is NetworkException || e is TimeoutException) {
      return Left(NetworkFailure(e.message));
    }

    if (e is ValidationException) {
      return Left(
        ValidationFailure(
          e.message,
          code: e.code,
          apiErrorCode: e.apiErrorCode,
        ),
      );
    }

    if (e is ServerException) {
      return Left(ServerFailure(e.message, e.statusCode));
    }

    if (e is NotFoundException) {
      return Left(ServerFailure(e.message, 404, code: e.code));
    }

    return Left(ServerFailure(e.message, 500));
  } catch (e, stackTrace) {
    logger.e('$logMessage (unexpected)', error: e, stackTrace: stackTrace);
    return const Left(ServerFailure('An unexpected error occurred', 500));
  }
}
