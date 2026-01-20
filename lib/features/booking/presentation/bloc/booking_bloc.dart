import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_reservation_usecase.dart';
import '../../domain/usecases/get_user_reservations_usecase.dart';
import '../../domain/usecases/get_active_reservations_usecase.dart';
import '../../domain/usecases/cancel_reservation_usecase.dart';
import 'booking_event.dart';
import 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final CreateReservationUseCase createReservationUseCase;
  final GetUserReservationsUseCase getUserReservationsUseCase;
  final GetActiveReservationsUseCase getActiveReservationsUseCase;
  final CancelReservationUseCase cancelReservationUseCase;

  BookingBloc({
    required this.createReservationUseCase,
    required this.getUserReservationsUseCase,
    required this.getActiveReservationsUseCase,
    required this.cancelReservationUseCase,
  }) : super(const BookingState()) {
    on<LoadUserReservations>(_onLoadUserReservations);
    on<LoadActiveReservations>(_onLoadActiveReservations);
    on<CreateReservation>(_onCreateReservation);
    on<CancelReservation>(_onCancelReservation);
    on<ClearBookingError>(_onClearBookingError);
    on<ResetBookingSuccess>(_onResetBookingSuccess);
  }

  Future<void> _onLoadUserReservations(
    LoadUserReservations event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await getUserReservationsUseCase(event.userId);

    result.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (reservations) =>
          emit(state.copyWith(isLoading: false, reservations: reservations)),
    );
  }

  Future<void> _onLoadActiveReservations(
    LoadActiveReservations event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await getActiveReservationsUseCase(event.userId);

    result.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (reservations) => emit(
        state.copyWith(isLoading: false, activeReservations: reservations),
      ),
    );
  }

  Future<void> _onCreateReservation(
    CreateReservation event,
    Emitter<BookingState> emit,
  ) async {
    emit(
      state.copyWith(isLoading: true, clearError: true, bookingSuccess: false),
    );

    final result = await createReservationUseCase(
      CreateReservationParams(
        userId: event.userId,
        vehicleId: event.vehicleId,
        locationId: event.location.id,
        spotId: event.spot.id,
        plateNumber: event.plateNumber,
        spotName: event.spot.slotName,
        locationName: event.location.name,
        startTime: event.startTime,
        endTime: event.endTime,
        bookingFee: event.bookingFee,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
          bookingSuccess: false,
        ),
      ),
      (reservation) => emit(
        state.copyWith(
          isLoading: false,
          lastCreatedReservation: reservation,
          bookingSuccess: true,
          // Add to active reservations
          activeReservations: [...state.activeReservations, reservation],
        ),
      ),
    );
  }

  Future<void> _onCancelReservation(
    CancelReservation event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await cancelReservationUseCase(event.reservationId);

    result.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (cancelledReservation) {
        // Remove from active reservations
        final updatedActiveReservations = state.activeReservations
            .where((r) => r.id != event.reservationId)
            .toList();

        // Update in all reservations list
        final updatedReservations = state.reservations.map((r) {
          if (r.id == event.reservationId) {
            return cancelledReservation;
          }
          return r;
        }).toList();

        emit(
          state.copyWith(
            isLoading: false,
            activeReservations: updatedActiveReservations,
            reservations: updatedReservations,
          ),
        );
      },
    );
  }

  void _onClearBookingError(
    ClearBookingError event,
    Emitter<BookingState> emit,
  ) {
    emit(state.copyWith(clearError: true));
  }

  void _onResetBookingSuccess(
    ResetBookingSuccess event,
    Emitter<BookingState> emit,
  ) {
    emit(state.copyWith(bookingSuccess: false, clearLastReservation: true));
  }
}
