import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/parking_session_model.dart';
import 'history_remote_data_source.dart';

class HistoryRemoteDataSourceImpl implements HistoryRemoteDataSource {
  final SupabaseClient supabaseClient;

  HistoryRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<ParkingSessionModel>> getParkingHistory() async {
    try {
      final response = await supabaseClient
          .from('parking_sessions')
          .select()
          .order('entry_time', ascending: false);

      return (response as List)
          .map((json) => ParkingSessionModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ParkingSessionModel>> getActiveSessions() async {
    try {
      final response = await supabaseClient
          .from('parking_sessions')
          .select()
          .isFilter('exit_time', null)
          .order('entry_time', ascending: false);

      return (response as List)
          .map((json) => ParkingSessionModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ParkingSessionModel>> getCompletedSessions() async {
    try {
      final response = await supabaseClient
          .from('parking_sessions')
          .select()
          .not('exit_time', 'is', null)
          .order('exit_time', ascending: false);

      return (response as List)
          .map((json) => ParkingSessionModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ParkingSessionModel> getParkingSessionById(int sessionId) async {
    try {
      final response = await supabaseClient
          .from('parking_sessions')
          .select()
          .eq('id', sessionId)
          .single();

      return ParkingSessionModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ParkingSessionModel>> searchByPlateNumber(
    String plateNumber,
  ) async {
    try {
      final response = await supabaseClient
          .from('parking_sessions')
          .select()
          .ilike('plate_number', '%$plateNumber%')
          .order('entry_time', ascending: false);

      return (response as List)
          .map((json) => ParkingSessionModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
