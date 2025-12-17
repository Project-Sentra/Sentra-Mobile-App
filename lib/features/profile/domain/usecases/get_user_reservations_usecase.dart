import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../parking/domain/entities/reservation.dart';
import '../repositories/profile_repository.dart';

class GetUserReservationsUseCase implements UseCase<List<Reservation>, String> {
  final ProfileRepository repository;

  GetUserReservationsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Reservation>>> call(String userId) {
    return repository.getUserReservations(userId);
  }
}
