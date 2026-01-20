import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/reservation.dart';
import '../repositories/booking_repository.dart';

class GetActiveReservationsUseCase
    implements UseCase<List<Reservation>, String> {
  final BookingRepository repository;

  GetActiveReservationsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Reservation>>> call(String visitorId) async {
    return await repository.getActiveReservations(visitorId);
  }
}
