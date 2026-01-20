import 'package:equatable/equatable.dart';
import '../../domain/entities/payment_method.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

class FetchPaymentMethods extends PaymentEvent {
  final String userId;

  const FetchPaymentMethods(this.userId);

  @override
  List<Object?> get props => [userId];
}

class AddPaymentMethod extends PaymentEvent {
  final String userId;
  final PaymentMethodType type;
  final String cardNumber;
  final String cardHolderName;
  final int expiryMonth;
  final int expiryYear;
  final String cvv;
  final bool isDefault;

  const AddPaymentMethod({
    required this.userId,
    required this.type,
    required this.cardNumber,
    required this.cardHolderName,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cvv,
    this.isDefault = false,
  });

  @override
  List<Object?> get props => [
    userId,
    type,
    cardNumber,
    cardHolderName,
    expiryMonth,
    expiryYear,
    cvv,
    isDefault,
  ];
}

class DeletePaymentMethod extends PaymentEvent {
  final String paymentMethodId;
  final String userId;

  const DeletePaymentMethod({
    required this.paymentMethodId,
    required this.userId,
  });

  @override
  List<Object?> get props => [paymentMethodId, userId];
}

class SetDefaultPaymentMethod extends PaymentEvent {
  final String userId;
  final String paymentMethodId;

  const SetDefaultPaymentMethod({
    required this.userId,
    required this.paymentMethodId,
  });

  @override
  List<Object?> get props => [userId, paymentMethodId];
}

class ProcessPayment extends PaymentEvent {
  final String userId;
  final String paymentMethodId;
  final double amount;
  final String? reservationId;
  final String? parkingSessionId;

  const ProcessPayment({
    required this.userId,
    required this.paymentMethodId,
    required this.amount,
    this.reservationId,
    this.parkingSessionId,
  });

  @override
  List<Object?> get props => [
    userId,
    paymentMethodId,
    amount,
    reservationId,
    parkingSessionId,
  ];
}

class FetchPaymentHistory extends PaymentEvent {
  final String userId;

  const FetchPaymentHistory(this.userId);

  @override
  List<Object?> get props => [userId];
}
