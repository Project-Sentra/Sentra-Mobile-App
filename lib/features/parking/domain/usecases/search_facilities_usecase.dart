import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/parking_slot.dart';
import '../repositories/parking_repository.dart';

class SearchSpotsUseCase implements UseCase<List<ParkingSlot>, String> {
  final ParkingRepository repository;

  SearchSpotsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ParkingSlot>>> call(String query) {
    return repository.searchSpots(query);
  }
}
