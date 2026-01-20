import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/add_payment_method_usecase.dart';
import '../../domain/usecases/delete_payment_method_usecase.dart';
import '../../domain/usecases/get_payment_history_usecase.dart';
import '../../domain/usecases/get_payment_methods_usecase.dart';
import '../../domain/usecases/process_payment_usecase.dart';
import 'payment_event.dart';
import 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final GetPaymentMethodsUseCase getPaymentMethodsUseCase;
  final AddPaymentMethodUseCase addPaymentMethodUseCase;
  final DeletePaymentMethodUseCase deletePaymentMethodUseCase;
  final ProcessPaymentUseCase processPaymentUseCase;
  final GetPaymentHistoryUseCase getPaymentHistoryUseCase;

  PaymentBloc({
    required this.getPaymentMethodsUseCase,
    required this.addPaymentMethodUseCase,
    required this.deletePaymentMethodUseCase,
    required this.processPaymentUseCase,
    required this.getPaymentHistoryUseCase,
  }) : super(const PaymentState()) {
    on<FetchPaymentMethods>(_onFetchPaymentMethods);
    on<AddPaymentMethod>(_onAddPaymentMethod);
    on<DeletePaymentMethod>(_onDeletePaymentMethod);
    on<ProcessPayment>(_onProcessPayment);
    on<FetchPaymentHistory>(_onFetchPaymentHistory);
  }

  Future<void> _onFetchPaymentMethods(
    FetchPaymentMethods event,
    Emitter<PaymentState> emit,
  ) async {
    emit(state.copyWith(status: PaymentBlocStatus.loading));

    final result = await getPaymentMethodsUseCase(event.userId);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: PaymentBlocStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (methods) => emit(
        state.copyWith(
          status: PaymentBlocStatus.loaded,
          paymentMethods: methods,
        ),
      ),
    );
  }

  Future<void> _onAddPaymentMethod(
    AddPaymentMethod event,
    Emitter<PaymentState> emit,
  ) async {
    emit(state.copyWith(status: PaymentBlocStatus.adding));

    final result = await addPaymentMethodUseCase(
      AddPaymentMethodParams(
        userId: event.userId,
        type: event.type,
        cardNumber: event.cardNumber,
        cardHolderName: event.cardHolderName,
        expiryMonth: event.expiryMonth,
        expiryYear: event.expiryYear,
        cvv: event.cvv,
        isDefault: event.isDefault,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: PaymentBlocStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (method) {
        final updatedMethods = [...state.paymentMethods, method];
        emit(
          state.copyWith(
            status: PaymentBlocStatus.added,
            paymentMethods: updatedMethods,
          ),
        );
      },
    );
  }

  Future<void> _onDeletePaymentMethod(
    DeletePaymentMethod event,
    Emitter<PaymentState> emit,
  ) async {
    emit(state.copyWith(status: PaymentBlocStatus.deleting));

    final result = await deletePaymentMethodUseCase(event.paymentMethodId);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: PaymentBlocStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (_) {
        final updatedMethods = state.paymentMethods
            .where((m) => m.id != event.paymentMethodId)
            .toList();
        emit(
          state.copyWith(
            status: PaymentBlocStatus.deleted,
            paymentMethods: updatedMethods,
          ),
        );
      },
    );
  }

  Future<void> _onProcessPayment(
    ProcessPayment event,
    Emitter<PaymentState> emit,
  ) async {
    emit(state.copyWith(status: PaymentBlocStatus.processing));

    final result = await processPaymentUseCase(
      ProcessPaymentParams(
        userId: event.userId,
        paymentMethodId: event.paymentMethodId,
        amount: event.amount,
        reservationId: event.reservationId,
        parkingSessionId: event.parkingSessionId,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: PaymentBlocStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (payment) {
        final updatedPayments = [payment, ...state.payments];
        emit(
          state.copyWith(
            status: PaymentBlocStatus.processed,
            payments: updatedPayments,
            lastPayment: payment,
          ),
        );
      },
    );
  }

  Future<void> _onFetchPaymentHistory(
    FetchPaymentHistory event,
    Emitter<PaymentState> emit,
  ) async {
    emit(state.copyWith(status: PaymentBlocStatus.loading));

    final result = await getPaymentHistoryUseCase(event.userId);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: PaymentBlocStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (payments) => emit(
        state.copyWith(status: PaymentBlocStatus.loaded, payments: payments),
      ),
    );
  }
}
