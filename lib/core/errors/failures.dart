import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final String? code;
  /// API error code number (e.g. 936) when the backend returns a numeric error_code in the response.
  final int? apiErrorCode;

  const Failure(this.message, {this.code, this.apiErrorCode});

  @override
  List<Object?> get props => [message, code, apiErrorCode];
}

class ServerFailure extends Failure {
  final int statusCode;
  const ServerFailure(super.message, this.statusCode, {super.code, super.apiErrorCode});

  @override
  List<Object?> get props => [statusCode, ...super.props];
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code, super.apiErrorCode});
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code, super.apiErrorCode});
}
