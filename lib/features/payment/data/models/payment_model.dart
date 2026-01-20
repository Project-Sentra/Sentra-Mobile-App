import '../../domain/entities/payment.dart';

class PaymentModel extends Payment {
  const PaymentModel({
    required super.id,
    required super.userId,
    super.reservationId,
    super.parkingSessionId,
    required super.paymentMethodId,
    required super.amount,
    super.currency,
    required super.status,
    super.transactionId,
    super.failureReason,
    required super.createdAt,
    super.completedAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      reservationId: json['reservation_id'] as String?,
      parkingSessionId: json['parking_session_id'] as String?,
      paymentMethodId: json['payment_method_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'LKR',
      status: _parsePaymentStatus(json['status'] as String),
      transactionId: json['transaction_id'] as String?,
      failureReason: json['failure_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'reservation_id': reservationId,
      'parking_session_id': parkingSessionId,
      'payment_method_id': paymentMethodId,
      'amount': amount,
      'currency': currency,
      'status': _paymentStatusToString(status),
      'transaction_id': transactionId,
      'failure_reason': failureReason,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  static PaymentStatus _parsePaymentStatus(String status) {
    switch (status) {
      case 'pending':
        return PaymentStatus.pending;
      case 'processing':
        return PaymentStatus.processing;
      case 'completed':
        return PaymentStatus.completed;
      case 'failed':
        return PaymentStatus.failed;
      case 'refunded':
        return PaymentStatus.refunded;
      default:
        return PaymentStatus.pending;
    }
  }

  static String _paymentStatusToString(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return 'pending';
      case PaymentStatus.processing:
        return 'processing';
      case PaymentStatus.completed:
        return 'completed';
      case PaymentStatus.failed:
        return 'failed';
      case PaymentStatus.refunded:
        return 'refunded';
    }
  }
}
