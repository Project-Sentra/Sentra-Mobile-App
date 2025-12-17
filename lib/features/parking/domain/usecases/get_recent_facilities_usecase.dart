import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/parking_facility.dart';
import '../repositories/parking_repository.dart';

class GetRecentFacilitiesUseCase
    implements UseCase<List<ParkingFacility>, String> {
  final ParkingRepository repository;

  GetRecentFacilitiesUseCase(this.repository);

  @override
  Future<Either<Failure, List<ParkingFacility>>> call(String userId) {
    return repository.getRecentFacilities(userId);
  }
}
