import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/reservation.dart';
import '../repositories/booking_repository.dart';

class CreateReservationUseCase
    implements UseCase<Reservation, CreateReservationParams> {
  final BookingRepository repository;

  CreateReservationUseCase(this.repository);

  @override
  Future<Either<Failure, Reservation>> call(
    CreateReservationParams params,
  ) async {
    return await repository.createReservation(
      userId: params.userId,
      vehicleId: params.vehicleId,
      locationId: params.locationId,
      spotId: params.spotId,
      plateNumber: params.plateNumber,
      spotName: params.spotName,
      locationName: params.locationName,
      startTime: params.startTime,
      endTime: params.endTime,
      bookingFee: params.bookingFee,
    );
  }
}

class CreateReservationParams {
  final String userId;
  final String? vehicleId;
  final int locationId;
  final int spotId;
  final String plateNumber;
  final String spotName;
  final String locationName;
  final DateTime startTime;
  final DateTime? endTime;
  final double bookingFee;

  CreateReservationParams({
    required this.userId,
    this.vehicleId,
    required this.locationId,
    required this.spotId,
    required this.plateNumber,
    required this.spotName,
    required this.locationName,
    required this.startTime,
    this.endTime,
    this.bookingFee = 0,
  });
}
