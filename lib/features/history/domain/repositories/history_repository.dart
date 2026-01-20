import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../parking/domain/entities/parking_session.dart';
import '../../../parking/domain/entities/parking_receipt.dart';
import '../../../parking/domain/entities/reservation.dart';

abstract class HistoryRepository {
  /// Get parking session history for a user
  Future<Either<Failure, List<ParkingSession>>> getParkingHistory(
    String userId,
  );

  /// Get active parking sessions for a user
  Future<Either<Failure, List<ParkingSession>>> getActiveSessions(
    String userId,
  );

  /// Get a specific parking session
  Future<Either<Failure, ParkingSession>> getParkingSessionById(
    String sessionId,
  );

  /// Get reservation history for a user
  Future<Either<Failure, List<Reservation>>> getReservationHistory(
    String userId,
  );

  /// Get active reservations for a user
  Future<Either<Failure, List<Reservation>>> getActiveReservations(
    String userId,
  );

  /// Get receipt for a parking session
  Future<Either<Failure, ParkingReceipt>> getReceipt(String sessionId);

  /// Get all receipts for a user
  Future<Either<Failure, List<ParkingReceipt>>> getReceipts(String userId);
}
