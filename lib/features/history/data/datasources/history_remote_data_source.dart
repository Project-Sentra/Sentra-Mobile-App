import '../models/parking_session_model.dart';

abstract class HistoryRemoteDataSource {
  /// Get all parking sessions (history)
  Future<List<ParkingSessionModel>> getParkingHistory();

  /// Get active parking sessions (no exit_time)
  Future<List<ParkingSessionModel>> getActiveSessions();

  /// Get completed parking sessions
  Future<List<ParkingSessionModel>> getCompletedSessions();

  /// Get a specific parking session
  Future<ParkingSessionModel> getParkingSessionById(int sessionId);

  /// Search sessions by plate number
  Future<List<ParkingSessionModel>> searchByPlateNumber(String plateNumber);
}
