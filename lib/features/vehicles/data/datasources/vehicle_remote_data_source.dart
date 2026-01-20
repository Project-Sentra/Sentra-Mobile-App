import '../models/vehicle_model.dart';

abstract class VehicleRemoteDataSource {
  /// Get all vehicles for a user
  Future<List<VehicleModel>> getVehicles(String userId);

  /// Get a single vehicle by ID
  Future<VehicleModel> getVehicleById(String vehicleId);

  /// Add a new vehicle
  Future<VehicleModel> addVehicle({
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
  Future<VehicleModel> updateVehicle({
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
  Future<void> deleteVehicle(String vehicleId);

  /// Set a vehicle as default (unsets others)
  Future<VehicleModel> setDefaultVehicle({
    required String userId,
    required String vehicleId,
  });
}
