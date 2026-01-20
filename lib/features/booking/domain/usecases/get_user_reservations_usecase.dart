import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/reservation.dart';
import '../repositories/booking_repository.dart';

class GetUserReservationsUseCase implements UseCase<List<Reservation>, String> {
  final BookingRepository repository;

  GetUserReservationsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Reservation>>> call(String visitorId) async {
    return await repository.getUserReservations(visitorId);
  }
}
