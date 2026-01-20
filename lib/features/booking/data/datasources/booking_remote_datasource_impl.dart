import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/reservation_model.dart';
import 'booking_remote_datasource.dart';

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final SupabaseClient supabaseClient;

  BookingRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<List<ReservationModel>> getUserReservations(String userId) async {
    try {
      final response = await supabaseClient
          .from('reservations')
          .select()
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
          .select()
          .eq('user_id', userId)
          .eq('status', 'active')
          .order('start_time', ascending: true);

      return (response as List)
          .map((json) => ReservationModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ReservationModel> getReservationById(int id) async {
    try {
      final response = await supabaseClient
          .from('reservations')
          .select()
          .eq('id', id)
          .single();

      return ReservationModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ReservationModel> createReservation({
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
      // First check if spot is available
      final spotCheck = await supabaseClient
          .from('parking_spots')
          .select('is_occupied')
          .eq('id', spotId)
          .single();

      if (spotCheck['is_occupied'] == true) {
        throw ServerException('This spot is already occupied');
      }

      // Check if there's an existing active reservation for this spot
      final existingReservation = await supabaseClient
          .from('reservations')
          .select()
          .eq('spot_id', spotId)
          .eq('status', 'active')
          .maybeSingle();

      if (existingReservation != null) {
        throw ServerException('This spot is already reserved');
      }

      // Create the reservation using the actual database schema
      final response = await supabaseClient
          .from('reservations')
          .insert({
            'user_id': userId,
            'spot_id': spotId,
            'location_id': locationId,
            'plate_number': plateNumber,
            'spot_name': spotName,
            'location_name': locationName,
            'start_time': startTime.toIso8601String(),
            'end_time': (endTime ?? startTime.add(const Duration(hours: 1)))
                .toIso8601String(),
            'status': 'active',
          })
          .select()
          .single();

      return ReservationModel.fromJson(response);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ReservationModel> cancelReservation(int reservationId) async {
    try {
      final response = await supabaseClient
          .from('reservations')
          .update({
            'status': 'cancelled',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', reservationId)
          .select()
          .single();

      return ReservationModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> isSpotAvailable(int spotId) async {
    try {
      // Check if spot is occupied
      final spotCheck = await supabaseClient
          .from('parking_spots')
          .select('is_occupied')
          .eq('id', spotId)
          .single();

      if (spotCheck['is_occupied'] == true) {
        return false;
      }

      // Check if there's an active reservation
      final reservation = await supabaseClient
          .from('reservations')
          .select()
          .eq('spot_id', spotId)
          .inFilter('status', ['pending', 'active'])
          .maybeSingle();

      return reservation == null;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
