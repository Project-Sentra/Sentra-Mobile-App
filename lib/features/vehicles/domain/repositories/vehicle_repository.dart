import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/vehicle.dart';

abstract class VehicleRepository {
  /// Get all vehicles for a user
  Future<Either<Failure, List<Vehicle>>> getVehicles(String userId);

  /// Get a single vehicle by ID
  Future<Either<Failure, Vehicle>> getVehicleById(String vehicleId);

  /// Add a new vehicle
  Future<Either<Failure, Vehicle>> addVehicle({
    required String userId,
    required String licensePlate,
    String? vehicleName,
    String? vehicleType,
    String? vehicleColor,
    String? vehicleMake,
    String? vehicleModel,
    bool isDefault = false,
  });

  /// Update an existing vehicle
  Future<Either<Failure, Vehicle>> updateVehicle({
    required String vehicleId,
    String? licensePlate,
    String? vehicleName,
    String? vehicleType,
    String? vehicleColor,
    String? vehicleMake,
    String? vehicleModel,
    bool? isDefault,
  });

  /// Delete a vehicle
  Future<Either<Failure, void>> deleteVehicle(String vehicleId);

  /// Set a vehicle as default
  Future<Either<Failure, Vehicle>> setDefaultVehicle({
    required String userId,
    required String vehicleId,
  });
}
