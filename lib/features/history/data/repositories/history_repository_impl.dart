import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure.dart';
import '../../../parking/domain/entities/parking_session.dart';
import '../../../parking/domain/entities/parking_receipt.dart';
import '../../../parking/domain/entities/reservation.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/history_remote_data_source.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryRemoteDataSource remoteDataSource;

  HistoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ParkingSession>>> getParkingHistory(
    String userId,
  ) async {
    try {
      final sessions = await remoteDataSource.getParkingHistory(userId);
      return Right(sessions);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ParkingSession>>> getActiveSessions(
    String userId,
  ) async {
    try {
      final sessions = await remoteDataSource.getActiveSessions(userId);
      return Right(sessions);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ParkingSession>> getParkingSessionById(
    String sessionId,
  ) async {
    try {
      final session = await remoteDataSource.getParkingSessionById(sessionId);
      return Right(session);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Reservation>>> getReservationHistory(
    String userId,
  ) async {
    try {
      final reservations = await remoteDataSource.getReservationHistory(userId);
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
  Future<Either<Failure, ParkingReceipt>> getReceipt(String sessionId) async {
    try {
      final receipt = await remoteDataSource.getReceipt(sessionId);
      return Right(receipt);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ParkingReceipt>>> getReceipts(
    String userId,
  ) async {
    try {
      final receipts = await remoteDataSource.getReceipts(userId);
      return Right(receipts);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
