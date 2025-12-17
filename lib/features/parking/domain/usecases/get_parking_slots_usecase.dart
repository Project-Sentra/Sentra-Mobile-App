import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/parking_slot.dart';
import '../repositories/parking_repository.dart';

class GetParkingSlotsUseCase implements UseCase<List<ParkingSlot>, String> {
  final ParkingRepository repository;

  GetParkingSlotsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ParkingSlot>>> call(String facilityId) {
    return repository.getParkingSlots(facilityId);
  }
}
