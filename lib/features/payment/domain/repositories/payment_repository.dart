import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/payment.dart';
import '../entities/payment_method.dart';

abstract class PaymentRepository {
  /// Get all payment methods for a user
  Future<Either<Failure, List<PaymentMethod>>> getPaymentMethods(String userId);

  /// Add a new payment method
  Future<Either<Failure, PaymentMethod>> addPaymentMethod({
    required String userId,
    required PaymentMethodType type,
    required String cardNumber,
    required String cardHolderName,
    required int expiryMonth,
    required int expiryYear,
    required String cvv,
    bool isDefault = false,
  });

  /// Delete a payment method
  Future<Either<Failure, void>> deletePaymentMethod(String paymentMethodId);

  /// Set a payment method as default
  Future<Either<Failure, PaymentMethod>> setDefaultPaymentMethod({
    required String userId,
    required String paymentMethodId,
  });

  /// Process a payment for parking session
  Future<Either<Failure, Payment>> processPayment({
    required String userId,
    required String paymentMethodId,
    required double amount,
    String? reservationId,
    String? parkingSessionId,
  });

  /// Get payment history for a user
  Future<Either<Failure, List<Payment>>> getPaymentHistory(String userId);

  /// Get a specific payment by ID
  Future<Either<Failure, Payment>> getPaymentById(String paymentId);
}
