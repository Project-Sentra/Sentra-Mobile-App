import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/payment.dart';
import '../repositories/payment_repository.dart';

class GetPaymentHistoryUseCase implements UseCase<List<Payment>, String> {
  final PaymentRepository repository;

  GetPaymentHistoryUseCase(this.repository);

  @override
  Future<Either<Failure, List<Payment>>> call(String userId) {
    return repository.getPaymentHistory(userId);
  }
}
