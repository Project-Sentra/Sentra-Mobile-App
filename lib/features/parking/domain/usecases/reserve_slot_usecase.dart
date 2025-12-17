import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/reservation.dart';
import '../repositories/parking_repository.dart';

class ReserveSlotUseCase implements UseCase<Reservation, ReserveSlotParams> {
  final ParkingRepository repository;

  ReserveSlotUseCase(this.repository);

  @override
  Future<Either<Failure, Reservation>> call(ReserveSlotParams params) {
    return repository.reserveSlot(
      slotId: params.slotId,
      facilityId: params.facilityId,
      userId: params.userId,
      durationMinutes: params.durationMinutes,
    );
  }
}

class ReserveSlotParams {
  final String slotId;
  final String facilityId;
  final String userId;
  final int durationMinutes;

  const ReserveSlotParams({
    required this.slotId,
    required this.facilityId,
    required this.userId,
    required this.durationMinutes,
  });
}
