import '../../domain/entities/payment_method.dart';
import '../models/payment_method_model.dart';
import '../models/payment_model.dart';

abstract class PaymentRemoteDataSource {
  /// Get all payment methods for a user
  Future<List<PaymentMethodModel>> getPaymentMethods(String userId);

  /// Add a new payment method
  Future<PaymentMethodModel> addPaymentMethod({
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
  Future<void> deletePaymentMethod(String paymentMethodId);

  /// Set a payment method as default
  Future<PaymentMethodModel> setDefaultPaymentMethod({
    required String userId,
    required String paymentMethodId,
  });

  /// Process a payment
  Future<PaymentModel> processPayment({
    required String userId,
    required String paymentMethodId,
    required double amount,
    String? reservationId,
    String? parkingSessionId,
  });

  /// Get payment history for a user
  Future<List<PaymentModel>> getPaymentHistory(String userId);

  /// Get a specific payment by ID
  Future<PaymentModel> getPaymentById(String paymentId);
}
