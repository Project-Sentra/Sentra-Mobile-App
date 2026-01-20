import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../parking/domain/entities/parking_session.dart';
import '../repositories/history_repository.dart';

class GetParkingHistoryUseCase
    implements UseCase<List<ParkingSession>, NoParams> {
  final HistoryRepository repository;

  GetParkingHistoryUseCase(this.repository);

  @override
  Future<Either<Failure, List<ParkingSession>>> call(NoParams params) {
    return repository.getParkingHistory();
  }
}
