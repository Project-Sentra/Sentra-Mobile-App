import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/payment_repository.dart';

class DeletePaymentMethodUseCase implements UseCase<void, String> {
  final PaymentRepository repository;

  DeletePaymentMethodUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String paymentMethodId) {
    return repository.deletePaymentMethod(paymentMethodId);
  }
}
