import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_parking_history_usecase.dart';
import '../../domain/usecases/get_active_sessions_usecase.dart';
import '../../domain/usecases/get_active_reservations_usecase.dart';
import '../../domain/usecases/get_receipts_usecase.dart';
import 'history_event.dart';
import 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetParkingHistoryUseCase getParkingHistoryUseCase;
  final GetActiveSessionsUseCase getActiveSessionsUseCase;
  final GetActiveReservationsUseCase getActiveReservationsUseCase;
  final GetReceiptsUseCase getReceiptsUseCase;

  HistoryBloc({
    required this.getParkingHistoryUseCase,
    required this.getActiveSessionsUseCase,
    required this.getActiveReservationsUseCase,
    required this.getReceiptsUseCase,
  }) : super(const HistoryState()) {
    on<FetchParkingHistory>(_onFetchParkingHistory);
    on<FetchActiveSessions>(_onFetchActiveSessions);
    on<FetchActiveReservations>(_onFetchActiveReservations);
    on<FetchReceipts>(_onFetchReceipts);
  }

  Future<void> _onFetchParkingHistory(
    FetchParkingHistory event,
    Emitter<HistoryState> emit,
  ) async {
    emit(state.copyWith(isLoadingHistory: true));

    final result = await getParkingHistoryUseCase(event.userId);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: HistoryStatus.error,
          isLoadingHistory: false,
          errorMessage: failure.message,
        ),
      ),
      (sessions) => emit(
        state.copyWith(
          status: HistoryStatus.loaded,
          isLoadingHistory: false,
          parkingHistory: sessions,
        ),
      ),
    );
  }

  Future<void> _onFetchActiveSessions(
    FetchActiveSessions event,
    Emitter<HistoryState> emit,
  ) async {
    emit(state.copyWith(isLoadingActive: true));

    final result = await getActiveSessionsUseCase(event.userId);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: HistoryStatus.error,
          isLoadingActive: false,
          errorMessage: failure.message,
        ),
      ),
      (sessions) => emit(
        state.copyWith(
          status: HistoryStatus.loaded,
          isLoadingActive: false,
          activeSessions: sessions,
        ),
      ),
    );
  }

  Future<void> _onFetchActiveReservations(
    FetchActiveReservations event,
    Emitter<HistoryState> emit,
  ) async {
    emit(state.copyWith(status: HistoryStatus.loading));

    final result = await getActiveReservationsUseCase(event.userId);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: HistoryStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (reservations) => emit(
        state.copyWith(
          status: HistoryStatus.loaded,
          activeReservations: reservations,
        ),
      ),
    );
  }

  Future<void> _onFetchReceipts(
    FetchReceipts event,
    Emitter<HistoryState> emit,
  ) async {
    emit(state.copyWith(status: HistoryStatus.loading));

    final result = await getReceiptsUseCase(event.userId);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: HistoryStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (receipts) => emit(
        state.copyWith(status: HistoryStatus.loaded, receipts: receipts),
      ),
    );
  }
}
