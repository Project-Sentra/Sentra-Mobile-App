import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/reservation.dart';

abstract class BookingRepository {
  Future<Either<Failure, List<Reservation>>> getUserReservations(String userId);
  Future<Either<Failure, List<Reservation>>> getActiveReservations(
    String userId,
  );
  Future<Either<Failure, Reservation>> getReservationById(String id);
  Future<Either<Failure, Reservation>> createReservation({
    required String userId,
    String? vehicleId,
    required int locationId,
    required int spotId,
    required String plateNumber,
    required String spotName,
    required String locationName,
    required DateTime startTime,
    DateTime? endTime,
    double bookingFee,
  });
  Future<Either<Failure, Reservation>> cancelReservation(String reservationId);
  Future<Either<Failure, bool>> isSpotAvailable(int spotId);
}
