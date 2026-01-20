import 'package:equatable/equatable.dart';

enum PaymentStatus { pending, processing, completed, failed, refunded }

class Payment extends Equatable {
  final String id;
  final String userId;
  final String? reservationId;
  final String? parkingSessionId;
  final String paymentMethodId;
  final double amount;
  final String currency;
  final PaymentStatus status;
  final String? transactionId;
  final String? failureReason;
  final DateTime createdAt;
  final DateTime? completedAt;

  const Payment({
    required this.id,
    required this.userId,
    this.reservationId,
    this.parkingSessionId,
    required this.paymentMethodId,
    required this.amount,
    this.currency = 'LKR',
    required this.status,
    this.transactionId,
    this.failureReason,
    required this.createdAt,
    this.completedAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    reservationId,
    parkingSessionId,
    paymentMethodId,
    amount,
    currency,
    status,
    transactionId,
    failureReason,
    createdAt,
    completedAt,
  ];

  Payment copyWith({
    String? id,
    String? userId,
    String? reservationId,
    String? parkingSessionId,
    String? paymentMethodId,
    double? amount,
    String? currency,
    PaymentStatus? status,
    String? transactionId,
    String? failureReason,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Payment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      reservationId: reservationId ?? this.reservationId,
      parkingSessionId: parkingSessionId ?? this.parkingSessionId,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      transactionId: transactionId ?? this.transactionId,
      failureReason: failureReason ?? this.failureReason,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
