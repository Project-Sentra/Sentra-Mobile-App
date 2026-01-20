import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../parking/domain/entities/reservation.dart';
import '../repositories/history_repository.dart';

class GetActiveReservationsUseCase
    implements UseCase<List<Reservation>, String> {
  final HistoryRepository repository;

  GetActiveReservationsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Reservation>>> call(String userId) {
    return repository.getActiveReservations(userId);
  }
}
