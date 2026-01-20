import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure.dart';
import '../../../parking/domain/entities/parking_session.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/history_remote_data_source.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryRemoteDataSource remoteDataSource;

  HistoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ParkingSession>>> getParkingHistory() async {
    try {
      final sessions = await remoteDataSource.getParkingHistory();
      return Right(sessions);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ParkingSession>>> getActiveSessions() async {
    try {
      final sessions = await remoteDataSource.getActiveSessions();
      return Right(sessions);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ParkingSession>>> getCompletedSessions() async {
    try {
      final sessions = await remoteDataSource.getCompletedSessions();
      return Right(sessions);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ParkingSession>> getParkingSessionById(
    int sessionId,
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
  Future<Either<Failure, List<ParkingSession>>> searchByPlateNumber(
    String plateNumber,
  ) async {
    try {
      final sessions = await remoteDataSource.searchByPlateNumber(plateNumber);
      return Right(sessions);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
