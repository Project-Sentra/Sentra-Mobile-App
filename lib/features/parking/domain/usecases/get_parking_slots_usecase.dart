import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/parking_slot.dart';
import '../repositories/parking_repository.dart';

class GetAvailableSpotsUseCase implements UseCase<List<ParkingSlot>, NoParams> {
  final ParkingRepository repository;

  GetAvailableSpotsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ParkingSlot>>> call(NoParams params) {
    return repository.getAvailableSpots();
  }
}
