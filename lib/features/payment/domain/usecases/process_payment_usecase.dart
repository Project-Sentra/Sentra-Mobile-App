import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/payment.dart';
import '../repositories/payment_repository.dart';

class ProcessPaymentUseCase implements UseCase<Payment, ProcessPaymentParams> {
  final PaymentRepository repository;

  ProcessPaymentUseCase(this.repository);

  @override
  Future<Either<Failure, Payment>> call(ProcessPaymentParams params) {
    return repository.processPayment(
      userId: params.userId,
      paymentMethodId: params.paymentMethodId,
      amount: params.amount,
      reservationId: params.reservationId,
      parkingSessionId: params.parkingSessionId,
    );
  }
}

class ProcessPaymentParams {
  final String userId;
  final String paymentMethodId;
  final double amount;
  final String? reservationId;
  final String? parkingSessionId;

  const ProcessPaymentParams({
    required this.userId,
    required this.paymentMethodId,
    required this.amount,
    this.reservationId,
    this.parkingSessionId,
  });
}
