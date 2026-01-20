import '../models/parking_session_model.dart';
import '../models/parking_receipt_model.dart';
import '../models/reservation_model.dart';

abstract class HistoryRemoteDataSource {
  /// Get parking session history for a user
  Future<List<ParkingSessionModel>> getParkingHistory(String userId);

  /// Get active parking sessions for a user
  Future<List<ParkingSessionModel>> getActiveSessions(String userId);

  /// Get a specific parking session
  Future<ParkingSessionModel> getParkingSessionById(String sessionId);

  /// Get reservation history for a user
  Future<List<ReservationModel>> getReservationHistory(String userId);

  /// Get active reservations for a user
  Future<List<ReservationModel>> getActiveReservations(String userId);

  /// Get receipt for a parking session
  Future<ParkingReceiptModel> getReceipt(String sessionId);

  /// Get all receipts for a user
  Future<List<ParkingReceiptModel>> getReceipts(String userId);
}
