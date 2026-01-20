import 'package:equatable/equatable.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/payment_method.dart';

enum PaymentBlocStatus {
  initial,
  loading,
  loaded,
  adding,
  added,
  deleting,
  deleted,
  processing,
  processed,
  error,
}

class PaymentState extends Equatable {
  final PaymentBlocStatus status;
  final List<PaymentMethod> paymentMethods;
  final List<Payment> payments;
  final Payment? lastPayment;
  final String? errorMessage;

  const PaymentState({
    this.status = PaymentBlocStatus.initial,
    this.paymentMethods = const [],
    this.payments = const [],
    this.lastPayment,
    this.errorMessage,
  });

  PaymentMethod? get defaultPaymentMethod {
    try {
      return paymentMethods.firstWhere((m) => m.isDefault);
    } catch (_) {
      return paymentMethods.isNotEmpty ? paymentMethods.first : null;
    }
  }

  PaymentState copyWith({
    PaymentBlocStatus? status,
    List<PaymentMethod>? paymentMethods,
    List<Payment>? payments,
    Payment? lastPayment,
    String? errorMessage,
  }) {
    return PaymentState(
      status: status ?? this.status,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      payments: payments ?? this.payments,
      lastPayment: lastPayment ?? this.lastPayment,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    paymentMethods,
    payments,
    lastPayment,
    errorMessage,
  ];
}
