import 'package:equatable/equatable.dart';
import '../../domain/entities/reservation.dart';

class BookingState extends Equatable {
  final bool isLoading;
  final List<Reservation> reservations;
  final List<Reservation> activeReservations;
  final String? errorMessage;
  final Reservation? lastCreatedReservation;
  final bool bookingSuccess;

  const BookingState({
    this.isLoading = false,
    this.reservations = const [],
    this.activeReservations = const [],
    this.errorMessage,
    this.lastCreatedReservation,
    this.bookingSuccess = false,
  });

  BookingState copyWith({
    bool? isLoading,
    List<Reservation>? reservations,
    List<Reservation>? activeReservations,
    String? errorMessage,
    bool clearError = false,
    Reservation? lastCreatedReservation,
    bool clearLastReservation = false,
    bool? bookingSuccess,
  }) {
    return BookingState(
      isLoading: isLoading ?? this.isLoading,
      reservations: reservations ?? this.reservations,
      activeReservations: activeReservations ?? this.activeReservations,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastCreatedReservation: clearLastReservation
          ? null
          : (lastCreatedReservation ?? this.lastCreatedReservation),
      bookingSuccess: bookingSuccess ?? this.bookingSuccess,
    );
  }

  bool hasActiveReservationForSpot(String slotId) {
    return activeReservations.any(
      (r) => r.slotId == slotId && r.status == ReservationStatus.active,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    reservations,
    activeReservations,
    errorMessage,
    lastCreatedReservation,
    bookingSuccess,
  ];
}
