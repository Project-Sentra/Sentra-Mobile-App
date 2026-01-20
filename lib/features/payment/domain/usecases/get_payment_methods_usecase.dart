import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/payment_method.dart';
import '../repositories/payment_repository.dart';

class GetPaymentMethodsUseCase implements UseCase<List<PaymentMethod>, String> {
  final PaymentRepository repository;

  GetPaymentMethodsUseCase(this.repository);

  @override
  Future<Either<Failure, List<PaymentMethod>>> call(String userId) {
    return repository.getPaymentMethods(userId);
  }
}
