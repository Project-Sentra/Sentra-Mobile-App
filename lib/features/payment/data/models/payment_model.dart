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
      id: json['id'].toString(),
      userId: json['user_id']?.toString() ?? '',
      reservationId: json['reservation_id']?.toString(),
      parkingSessionId:
          (json['session_id'] ?? json['parking_session_id'])?.toString(),
      paymentMethodId: (json['payment_method_id'] ??
              json['payment_method'] ??
              'wallet')
          .toString(),
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'LKR',
      status: _parsePaymentStatus(
        (json['payment_status'] ?? json['status'] ?? 'pending') as String,
      ),
      transactionId:
          json['transaction_ref'] as String? ??
          json['transaction_id'] as String?,
      failureReason: json['failure_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'].toString()),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final parsedMethodId = int.tryParse(paymentMethodId);
    final normalizedMethod = (() {
      final normalized = paymentMethodId.trim().toLowerCase();
      if (normalized == 'cash') return 'cash';
      // Stripe is the provider but the DB payment_method is typically 'card'.
      if (normalized == 'stripe') return 'card';
      if (normalized == 'card') return 'card';
      // If this looks like a DB id (int/uuid), store method as 'card' to satisfy CHECK constraints.
      final uuidRegex = RegExp(
        r'^[0-9a-fA-F]{8}-'
        r'[0-9a-fA-F]{4}-'
        r'[0-9a-fA-F]{4}-'
        r'[0-9a-fA-F]{4}-'
        r'[0-9a-fA-F]{12}$',
      );
      if (parsedMethodId != null || uuidRegex.hasMatch(normalized)) return 'card';
      return 'card';
    })();
    return {
      'id': id,
      'user_id': userId,
      'reservation_id': reservationId,
      'session_id': parkingSessionId,
      'payment_method_id': parsedMethodId,
      'payment_method': normalizedMethod,
      'amount': amount,
      'currency': currency,
      'payment_status': _paymentStatusToString(status),
      'transaction_ref': transactionId,
      'created_at': createdAt.toIso8601String(),
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
