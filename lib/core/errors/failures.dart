import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}

class ServerFailure extends Failure {
  final int statusCode;
  const ServerFailure(String message, this.statusCode, {String? code})
    : super(message, code: code);

  @override
  List<Object?> get props => [statusCode, ...super.props];
}

class NetworkFailure extends Failure {
  const NetworkFailure(String message, {String? code})
    : super(message, code: code);
}

class ValidationFailure extends Failure {
  const ValidationFailure(String message, {String? code})
    : super(message, code: code);
}
