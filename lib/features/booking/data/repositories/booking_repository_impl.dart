import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/reservation.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_datasource.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource remoteDataSource;

  BookingRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Reservation>>> getUserReservations(
    String userId,
  ) async {
    try {
      final reservations = await remoteDataSource.getUserReservations(userId);
      return Right(reservations);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Reservation>>> getActiveReservations(
    String userId,
  ) async {
    try {
      final reservations = await remoteDataSource.getActiveReservations(userId);
      return Right(reservations);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Reservation>> getReservationById(String id) async {
    try {
      final reservation = await remoteDataSource.getReservationById(id);
      return Right(reservation);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Reservation>> createReservation({
    required String userId,
    String? vehicleId,
    required int locationId,
    required int spotId,
    required String plateNumber,
    required String spotName,
    required String locationName,
    required DateTime startTime,
    DateTime? endTime,
    double bookingFee = 0,
  }) async {
    try {
      final reservation = await remoteDataSource.createReservation(
        userId: userId,
        vehicleId: vehicleId,
        locationId: locationId,
        spotId: spotId,
        plateNumber: plateNumber,
        spotName: spotName,
        locationName: locationName,
        startTime: startTime,
        endTime: endTime,
        bookingFee: bookingFee,
      );
      return Right(reservation);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Reservation>> cancelReservation(
    String reservationId,
  ) async {
    try {
      final reservation = await remoteDataSource.cancelReservation(
        reservationId,
      );
      return Right(reservation);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isSpotAvailable(int spotId) async {
    try {
      final isAvailable = await remoteDataSource.isSpotAvailable(spotId);
      return Right(isAvailable);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
