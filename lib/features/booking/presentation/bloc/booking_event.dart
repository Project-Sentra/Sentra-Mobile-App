import 'package:equatable/equatable.dart';
import '../../../parking/domain/entities/parking_slot.dart';
import '../../../parking/domain/entities/parking_location.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserReservations extends BookingEvent {
  final String userId;

  const LoadUserReservations(this.userId);

  @override
  List<Object?> get props => [userId];
}

class LoadActiveReservations extends BookingEvent {
  final String userId;

  const LoadActiveReservations(this.userId);

  @override
  List<Object?> get props => [userId];
}

class CreateReservation extends BookingEvent {
  final String userId;
  final String? vehicleId;
  final ParkingLocation location;
  final ParkingSlot spot;
  final String plateNumber;
  final DateTime startTime;
  final DateTime? endTime;
  final double bookingFee;

  const CreateReservation({
    required this.userId,
    this.vehicleId,
    required this.location,
    required this.spot,
    required this.plateNumber,
    required this.startTime,
    this.endTime,
    this.bookingFee = 0,
  });

  @override
  List<Object?> get props => [
    userId,
    vehicleId,
    location,
    spot,
    plateNumber,
    startTime,
    endTime,
    bookingFee,
  ];
}

class CancelReservation extends BookingEvent {
  final String reservationId;
  final String userId;

  const CancelReservation({required this.reservationId, required this.userId});

  @override
  List<Object?> get props => [reservationId, userId];
}

class ClearBookingError extends BookingEvent {}

class ResetBookingSuccess extends BookingEvent {}
