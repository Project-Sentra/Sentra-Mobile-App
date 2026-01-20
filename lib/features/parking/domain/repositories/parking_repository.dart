import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/parking_location.dart';
import '../entities/parking_slot.dart';

abstract class ParkingRepository {
  // Locations
  Future<Either<Failure, List<ParkingLocation>>> getParkingLocations();
  Future<Either<Failure, ParkingLocation>> getParkingLocationById(int id);
  Future<Either<Failure, List<ParkingLocation>>> searchLocations(String query);

  // Spots
  Future<Either<Failure, List<ParkingSlot>>> getParkingSpots();
  Future<Either<Failure, List<ParkingSlot>>> getSpotsByLocation(int locationId);
  Future<Either<Failure, ParkingSlot>> getParkingSpotById(int id);
  Future<Either<Failure, List<ParkingSlot>>> searchSpots(String query);
  Future<Either<Failure, List<ParkingSlot>>> getAvailableSpots();
  Future<Either<Failure, List<ParkingSlot>>> getAvailableSpotsByLocation(
    int locationId,
  );
}
