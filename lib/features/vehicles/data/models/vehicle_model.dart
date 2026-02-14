import '../../domain/entities/vehicle.dart';

class VehicleModel extends Vehicle {
  const VehicleModel({
    required super.id,
    required super.userId,
    required super.licensePlate,
    super.vehicleName,
    super.vehicleType,
    super.vehicleColor,
    super.vehicleMake,
    super.vehicleModel,
    super.isDefault,
    required super.createdAt,
    super.updatedAt,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      licensePlate:
          (json['plate_number'] ?? json['license_plate']) as String,
      vehicleName: json['vehicle_name'] as String?,
      vehicleType: json['vehicle_type'] as String?,
      vehicleColor: json['color'] as String? ?? json['vehicle_color'] as String?,
      vehicleMake: json['make'] as String? ?? json['vehicle_make'] as String?,
      vehicleModel: json['model'] as String? ?? json['vehicle_model'] as String?,
      isDefault: json['is_default'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'].toString()),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'plate_number': licensePlate,
      'vehicle_type': vehicleType,
      'color': vehicleColor,
      'make': vehicleMake,
      'model': vehicleModel,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory VehicleModel.fromEntity(Vehicle vehicle) {
    return VehicleModel(
      id: vehicle.id,
      userId: vehicle.userId,
      licensePlate: vehicle.licensePlate,
      vehicleName: vehicle.vehicleName,
      vehicleType: vehicle.vehicleType,
      vehicleColor: vehicle.vehicleColor,
      vehicleMake: vehicle.vehicleMake,
      vehicleModel: vehicle.vehicleModel,
      isDefault: vehicle.isDefault,
      createdAt: vehicle.createdAt,
      updatedAt: vehicle.updatedAt,
    );
  }
}
