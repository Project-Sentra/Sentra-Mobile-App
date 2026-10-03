import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/user_helpers.dart';
import '../models/parking_session_model.dart';
import 'history_remote_data_source.dart';
import '../../../../core/utils/plate_utils.dart';

/// Session columns plus the facility (name, rate) and the payment for receipts.
const _sessionSelect =
    '*, facilities(name, hourly_rate), '
    'payments(id, amount, payment_method, payment_status, transaction_ref, created_at)';

class HistoryRemoteDataSourceImpl implements HistoryRemoteDataSource {
  final SupabaseClient supabaseClient;

  HistoryRemoteDataSourceImpl({required this.supabaseClient});

  /// Ids of every vehicle the signed-in driver has registered (including
  /// removed ones, so their past sessions stay visible). Sessions are always
  /// filtered by these ids: a driver must only ever see their own parking.
  Future<List<int>> _ownVehicleIds() async {
    final authUser = supabaseClient.auth.currentUser;
    if (authUser == null) {
      throw const ServerException('User not authenticated');
    }
    final dbUserId = await getUserIdFromAuth(supabaseClient, authUser.id);
    final rows = await supabaseClient
        .from('vehicles')
        .select('id')
        .eq('user_id', dbUserId);
    return (rows as List).map((r) => (r['id'] as num).toInt()).toList();
  }

  Future<List<ParkingSessionModel>> _ownSessions({
    bool? active,
    String orderBy = 'entry_time',
    String? plateQuery,
  }) async {
    try {
      final vehicleIds = await _ownVehicleIds();
      if (vehicleIds.isEmpty) return [];

      var query = supabaseClient
          .from('parking_sessions')
          .select(_sessionSelect)
          .inFilter('vehicle_id', vehicleIds);
      if (active == true) query = query.isFilter('exit_time', null);
      if (active == false) query = query.not('exit_time', 'is', null);
      if (plateQuery != null) {
        query = query.ilike('plate_number', '%$plateQuery%');
      }

      final response = await query.order(orderBy, ascending: false);
      return (response as List)
          .map((json) => ParkingSessionModel.fromJson(json))
          .toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ParkingSessionModel>> getParkingHistory() => _ownSessions();

  @override
  Future<List<ParkingSessionModel>> getActiveSessions() =>
      _ownSessions(active: true);

  @override
  Future<List<ParkingSessionModel>> getCompletedSessions() =>
      _ownSessions(active: false, orderBy: 'exit_time');

  @override
  Future<ParkingSessionModel> getParkingSessionById(int sessionId) async {
    try {
      final vehicleIds = await _ownVehicleIds();
      final response = await supabaseClient
          .from('parking_sessions')
          .select(_sessionSelect)
          .eq('id', sessionId)
          .inFilter('vehicle_id', vehicleIds)
          .maybeSingle();
      if (response == null) {
        throw const ServerException('Parking session not found');
      }
      return ParkingSessionModel.fromJson(response);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ParkingSessionModel>> searchByPlateNumber(String plateNumber) =>
      _ownSessions(plateQuery: normalizePlate(plateNumber));
}
