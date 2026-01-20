import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/parking_slot.dart';
import '../repositories/parking_repository.dart';

class GetSpotsByLocationUseCase implements UseCase<List<ParkingSlot>, int> {
  final ParkingRepository repository;

  GetSpotsByLocationUseCase(this.repository);

  @override
  Future<Either<Failure, List<ParkingSlot>>> call(int locationId) {
    return repository.getSpotsByLocation(locationId);
  }
}
