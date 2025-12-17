import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/parking_facility.dart';
import '../entities/parking_slot.dart';
import '../entities/reservation.dart';

abstract class ParkingRepository {
  Future<Either<Failure, List<ParkingFacility>>> getParkingFacilities();

  Future<Either<Failure, ParkingFacility>> getParkingFacilityById(String id);

  Future<Either<Failure, List<ParkingFacility>>> searchFacilities(String query);

  Future<Either<Failure, List<ParkingFacility>>> getRecentFacilities(
    String userId,
  );

  Future<Either<Failure, List<ParkingSlot>>> getParkingSlots(String facilityId);

  Future<Either<Failure, ParkingSlot>> getParkingSlotById(String slotId);

  Future<Either<Failure, Reservation>> reserveSlot({
    required String slotId,
    required String facilityId,
    required String userId,
    required int durationMinutes,
  });

  Future<Either<Failure, void>> cancelReservation(String reservationId);

  Future<Either<Failure, void>> addToRecentFacilities({
    required String userId,
    required String facilityId,
  });
}
