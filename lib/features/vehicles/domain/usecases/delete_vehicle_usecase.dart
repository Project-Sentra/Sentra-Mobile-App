import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/vehicle_repository.dart';

class DeleteVehicleUseCase implements UseCase<void, String> {
  final VehicleRepository repository;

  DeleteVehicleUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String vehicleId) {
    return repository.deleteVehicle(vehicleId);
  }
}
