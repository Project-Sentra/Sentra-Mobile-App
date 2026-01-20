import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../parking/domain/entities/parking_session.dart';

abstract class HistoryRepository {
  /// Get all parking sessions (history)
  Future<Either<Failure, List<ParkingSession>>> getParkingHistory();

  /// Get active parking sessions (no exit_time)
  Future<Either<Failure, List<ParkingSession>>> getActiveSessions();

  /// Get completed parking sessions
  Future<Either<Failure, List<ParkingSession>>> getCompletedSessions();

  /// Get a specific parking session
  Future<Either<Failure, ParkingSession>> getParkingSessionById(int sessionId);

  /// Search sessions by plate number
  Future<Either<Failure, List<ParkingSession>>> searchByPlateNumber(
    String plateNumber,
  );
}
