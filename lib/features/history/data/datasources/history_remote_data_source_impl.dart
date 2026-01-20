import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/parking_session_model.dart';
import '../models/parking_receipt_model.dart';
import '../models/reservation_model.dart';
import 'history_remote_data_source.dart';

class HistoryRemoteDataSourceImpl implements HistoryRemoteDataSource {
  final SupabaseClient supabaseClient;

  HistoryRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<ParkingSessionModel>> getParkingHistory(String userId) async {
    try {
      final response = await supabaseClient
          .from('parking_sessions')
          .select('''
            *,
            facilities:facility_id(name, address),
            vehicles:vehicle_id(license_plate),
            slots:slot_id(slot_number)
          ''')
          .eq('user_id', userId)
          .order('entry_time', ascending: false);

      return (response as List)
          .map((json) => ParkingSessionModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ParkingSessionModel>> getActiveSessions(String userId) async {
    try {
      final response = await supabaseClient
          .from('parking_sessions')
          .select('''
            *,
            facilities:facility_id(name, address),
            vehicles:vehicle_id(license_plate),
            slots:slot_id(slot_number)
          ''')
          .eq('user_id', userId)
          .eq('status', 'active')
          .order('entry_time', ascending: false);

      return (response as List)
          .map((json) => ParkingSessionModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ParkingSessionModel> getParkingSessionById(String sessionId) async {
    try {
      final response = await supabaseClient
          .from('parking_sessions')
          .select('''
            *,
            facilities:facility_id(name, address),
            vehicles:vehicle_id(license_plate),
            slots:slot_id(slot_number)
          ''')
          .eq('id', sessionId)
          .single();

      return ParkingSessionModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ReservationModel>> getReservationHistory(String userId) async {
    try {
      final response = await supabaseClient
          .from('reservations')
          .select('''
            *,
            facilities:facility_id(name),
            slots:slot_id(slot_number)
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => ReservationModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ReservationModel>> getActiveReservations(String userId) async {
    try {
      final response = await supabaseClient
          .from('reservations')
          .select('''
            *,
            facilities:facility_id(name),
            slots:slot_id(slot_number)
          ''')
          .eq('user_id', userId)
          .eq('status', 'active')
          .gte('end_time', DateTime.now().toIso8601String())
          .order('start_time', ascending: true);

      return (response as List)
          .map((json) => ReservationModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ParkingReceiptModel> getReceipt(String sessionId) async {
    try {
      final response = await supabaseClient
          .from('parking_receipts')
          .select()
          .eq('parking_session_id', sessionId)
          .single();

      return ParkingReceiptModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ParkingReceiptModel>> getReceipts(String userId) async {
    try {
      final response = await supabaseClient
          .from('parking_receipts')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => ParkingReceiptModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
