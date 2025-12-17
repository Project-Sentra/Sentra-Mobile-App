import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/parking_facility.dart';
import '../repositories/parking_repository.dart';

class GetParkingFacilitiesUseCase
    implements UseCase<List<ParkingFacility>, NoParams> {
  final ParkingRepository repository;

  GetParkingFacilitiesUseCase(this.repository);

  @override
  Future<Either<Failure, List<ParkingFacility>>> call(NoParams params) {
    return repository.getParkingFacilities();
  }
}
