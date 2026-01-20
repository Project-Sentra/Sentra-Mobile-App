import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/reservation.dart';
import '../repositories/booking_repository.dart';

class CancelReservationUseCase implements UseCase<Reservation, String> {
  final BookingRepository repository;

  CancelReservationUseCase(this.repository);

  @override
  Future<Either<Failure, Reservation>> call(String reservationId) async {
    return await repository.cancelReservation(reservationId);
  }
}
