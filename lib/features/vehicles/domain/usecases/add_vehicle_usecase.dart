import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/vehicle.dart';
import '../repositories/vehicle_repository.dart';

class AddVehicleUseCase implements UseCase<Vehicle, AddVehicleParams> {
  final VehicleRepository repository;

  AddVehicleUseCase(this.repository);

  @override
  Future<Either<Failure, Vehicle>> call(AddVehicleParams params) {
    return repository.addVehicle(
      userId: params.userId,
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

class AddVehicleParams {
  final String userId;
  final String licensePlate;
  final String? vehicleName;
  final String? vehicleType;
  final String? vehicleColor;
  final String? vehicleMake;
  final String? vehicleModel;
  final bool isDefault;

  const AddVehicleParams({
    required this.userId,
    required this.licensePlate,
    this.vehicleName,
    this.vehicleType,
    this.vehicleColor,
    this.vehicleMake,
    this.vehicleModel,
    this.isDefault = false,
  });
}
