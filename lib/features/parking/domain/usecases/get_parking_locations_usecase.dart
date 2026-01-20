import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/parking_location.dart';
import '../repositories/parking_repository.dart';

class GetParkingLocationsUseCase
    implements UseCase<List<ParkingLocation>, NoParams> {
  final ParkingRepository repository;

  GetParkingLocationsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ParkingLocation>>> call(NoParams params) {
    return repository.getParkingLocations();
  }
}
