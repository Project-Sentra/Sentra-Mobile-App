import 'package:dartz/dartz.dart';
import 'package:sentra_mobile/core/errors/errors.dart';
// import 'failure.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams {
  const NoParams();
}
