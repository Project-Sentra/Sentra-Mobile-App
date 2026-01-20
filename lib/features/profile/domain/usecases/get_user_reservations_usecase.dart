import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../parking/domain/entities/parking_session.dart';
import '../repositories/profile_repository.dart';

class GetUserSessionsUseCase implements UseCase<List<ParkingSession>, String> {
  final ProfileRepository repository;

  GetUserSessionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ParkingSession>>> call(String plateNumber) {
    return repository.getUserSessions(plateNumber);
  }
}
