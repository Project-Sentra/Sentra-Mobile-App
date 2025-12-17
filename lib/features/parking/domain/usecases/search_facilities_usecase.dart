import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/parking_facility.dart';
import '../repositories/parking_repository.dart';

class SearchFacilitiesUseCase
    implements UseCase<List<ParkingFacility>, String> {
  final ParkingRepository repository;

  SearchFacilitiesUseCase(this.repository);

  @override
  Future<Either<Failure, List<ParkingFacility>>> call(String query) {
    return repository.searchFacilities(query);
  }
}
