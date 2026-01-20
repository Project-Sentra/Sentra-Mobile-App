import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/payment_method.dart';
import '../repositories/payment_repository.dart';

class AddPaymentMethodUseCase
    implements UseCase<PaymentMethod, AddPaymentMethodParams> {
  final PaymentRepository repository;

  AddPaymentMethodUseCase(this.repository);

  @override
  Future<Either<Failure, PaymentMethod>> call(AddPaymentMethodParams params) {
    return repository.addPaymentMethod(
      userId: params.userId,
      type: params.type,
      cardNumber: params.cardNumber,
      cardHolderName: params.cardHolderName,
      expiryMonth: params.expiryMonth,
      expiryYear: params.expiryYear,
      cvv: params.cvv,
      isDefault: params.isDefault,
    );
  }
}

class AddPaymentMethodParams {
  final String userId;
  final PaymentMethodType type;
  final String cardNumber;
  final String cardHolderName;
  final int expiryMonth;
  final int expiryYear;
  final String cvv;
  final bool isDefault;

  const AddPaymentMethodParams({
    required this.userId,
    required this.type,
    required this.cardNumber,
    required this.cardHolderName,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cvv,
    this.isDefault = false,
  });
}
