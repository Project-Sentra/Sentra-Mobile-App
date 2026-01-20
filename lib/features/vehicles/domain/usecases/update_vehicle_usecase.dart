import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/vehicle.dart';
import '../repositories/vehicle_repository.dart';

class UpdateVehicleUseCase implements UseCase<Vehicle, UpdateVehicleParams> {
  final VehicleRepository repository;

  UpdateVehicleUseCase(this.repository);

  @override
  Future<Either<Failure, Vehicle>> call(UpdateVehicleParams params) {
    return repository.updateVehicle(
      vehicleId: params.vehicleId,
      licensePlate: params.licensePlate,
      vehicleName: params.vehicleName,
      vehicleType: params.vehicleType,
      vehicleColor: params.vehicleColor,
      vehicleMake: params.vehicleMake,
      vehicleModel: params.vehicleModel,
      isDefault: params.isDefault,
    );
  }
}

class UpdateVehicleParams {
  final String vehicleId;
  final String? licensePlate;
  final String? vehicleName;
  final String? vehicleType;
  final String? vehicleColor;
  final String? vehicleMake;
  final String? vehicleModel;
  final bool? isDefault;

  const UpdateVehicleParams({
    required this.vehicleId,
    this.licensePlate,
    this.vehicleName,
    this.vehicleType,
    this.vehicleColor,
    this.vehicleMake,
    this.vehicleModel,
    this.isDefault,
  });
}
