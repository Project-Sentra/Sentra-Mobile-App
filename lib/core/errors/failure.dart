import 'package:equatable/equatable.dart';
import 'error_sanitizer.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  ServerFailure([String message = 'Server error occurred'])
      : super(ErrorSanitizer.sanitize(message));
}

class CacheFailure extends Failure {
  CacheFailure([String message = 'Cache error occurred'])
      : super(ErrorSanitizer.sanitize(message));
}

class NetworkFailure extends Failure {
  NetworkFailure([String message = 'Network error occurred'])
      : super(ErrorSanitizer.sanitize(message));
}

class AuthFailure extends Failure {
  AuthFailure([String message = 'Authentication error occurred'])
      : super(ErrorSanitizer.sanitize(message));
}

class ValidationFailure extends Failure {
  ValidationFailure([String message = 'Validation error occurred'])
      : super(ErrorSanitizer.sanitize(message));
}
