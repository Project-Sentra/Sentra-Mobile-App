import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/vehicle.dart';
import '../repositories/vehicle_repository.dart';

class GetVehiclesUseCase implements UseCase<List<Vehicle>, String> {
  final VehicleRepository repository;

  GetVehiclesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Vehicle>>> call(String userId) {
    return repository.getVehicles(userId);
  }
}
