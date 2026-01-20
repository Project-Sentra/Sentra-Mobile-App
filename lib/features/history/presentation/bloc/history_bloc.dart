import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_parking_history_usecase.dart';
import '../../domain/usecases/get_active_sessions_usecase.dart';
import 'history_event.dart';
import 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetParkingHistoryUseCase getParkingHistoryUseCase;
  final GetActiveSessionsUseCase getActiveSessionsUseCase;

  HistoryBloc({
    required this.getParkingHistoryUseCase,
    required this.getActiveSessionsUseCase,
  }) : super(const HistoryState()) {
    on<FetchParkingHistory>(_onFetchParkingHistory);
    on<FetchActiveSessions>(_onFetchActiveSessions);
  }

  Future<void> _onFetchParkingHistory(
    FetchParkingHistory event,
    Emitter<HistoryState> emit,
  ) async {
    emit(state.copyWith(isLoadingHistory: true));

    final result = await getParkingHistoryUseCase(const NoParams());

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

    final result = await getActiveSessionsUseCase(const NoParams());

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
}
