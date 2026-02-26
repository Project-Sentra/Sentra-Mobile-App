import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/user_helpers.dart';
import '../models/reservation_model.dart';
import 'booking_remote_datasource.dart';

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final SupabaseClient supabaseClient;

  BookingRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<List<ReservationModel>> getUserReservations(String userId) async {
    try {
      final dbUserId = await getUserIdFromAuth(supabaseClient, userId);
      final response = await supabaseClient
          .from('reservations')
          .select('*, facilities(name), parking_spots(spot_name)')
          .eq('user_id', dbUserId)
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
      final dbUserId = await getUserIdFromAuth(supabaseClient, userId);
      final response = await supabaseClient
          .from('reservations')
          .select('*, facilities(name), parking_spots(spot_name)')
          .eq('user_id', dbUserId)
          .inFilter('status', ['pending', 'confirmed', 'checked_in'])
          .order('reserved_start', ascending: true);

      return (response as List)
          .map((json) => ReservationModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ReservationModel> getReservationById(String id) async {
    try {
      final parsedId = int.tryParse(id) ?? id;
      final response = await supabaseClient
          .from('reservations')
          .select('*, facilities(name), parking_spots(spot_name)')
          .eq('id', parsedId)
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
      final dbUserId = await getUserIdFromAuth(supabaseClient, userId);
      int? parsedVehicleId = vehicleId != null ? int.tryParse(vehicleId) : null;
      if (parsedVehicleId == null) {
        final existingVehicle = await supabaseClient
            .from('vehicles')
            .select('id')
            .eq('user_id', dbUserId)
            .eq('plate_number', plateNumber.toUpperCase())
            .maybeSingle();
        if (existingVehicle != null) {
          parsedVehicleId = existingVehicle['id'] as int?;
        } else {
          final newVehicle = await supabaseClient
              .from('vehicles')
              .insert({
                'user_id': dbUserId,
                'plate_number': plateNumber.toUpperCase(),
                'vehicle_type': 'car',
                'is_active': true,
              })
              .select('id')
              .single();
          parsedVehicleId = newVehicle['id'] as int?;
        }
      }
      if (parsedVehicleId == null) {
        throw ServerException('Unable to resolve vehicle for reservation');
      }
      // First check if spot is available
      final spotCheck = await supabaseClient
          .from('parking_spots')
          .select('is_occupied, is_reserved')
          .eq('id', spotId)
          .single();

      if (spotCheck['is_occupied'] == true || spotCheck['is_reserved'] == true) {
        throw ServerException('This spot is already occupied');
      }

      // Check if there's an existing active reservation for this spot
      final existingReservation = await supabaseClient
          .from('reservations')
          .select()
          .eq('spot_id', spotId)
          .inFilter('status', ['pending', 'confirmed', 'checked_in'])
          .maybeSingle();

      if (existingReservation != null) {
        throw ServerException('This spot is already reserved');
      }

      // Create the reservation using the actual database schema
      final response = await supabaseClient
          .from('reservations')
          .insert({
            'user_id': dbUserId,
            'vehicle_id': parsedVehicleId,
            'facility_id': locationId,
            'spot_id': spotId,
            'reserved_start': startTime.toIso8601String(),
            'reserved_end': (endTime ?? startTime.add(const Duration(hours: 1)))
                .toIso8601String(),
            'status': 'pending',
            'amount': bookingFee.round(),
            'payment_status': 'pending',
            'notes': 'Plate $plateNumber',
          })
          .select('*, facilities(name), parking_spots(spot_name)')
          .single();

      await supabaseClient
          .from('parking_spots')
          .update({'is_reserved': true})
          .eq('id', spotId);

      return ReservationModel.fromJson(response);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ReservationModel> cancelReservation(String reservationId) async {
    try {
      final parsedId = int.tryParse(reservationId) ?? reservationId;
      final response = await supabaseClient
          .from('reservations')
          .update({
            'status': 'cancelled',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', parsedId)
          .select('*, facilities(name), parking_spots(spot_name)')
          .single();

      final spotId = response['spot_id'];
      if (spotId != null) {
        await supabaseClient
            .from('parking_spots')
            .update({'is_reserved': false})
            .eq('id', spotId);
      }

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
          .select('is_occupied, is_reserved')
          .eq('id', spotId)
          .single();

      if (spotCheck['is_occupied'] == true || spotCheck['is_reserved'] == true) {
        return false;
      }

      // Check if there's an active reservation
      final reservation = await supabaseClient
          .from('reservations')
          .select()
          .eq('spot_id', spotId)
          .inFilter('status', ['pending', 'confirmed', 'checked_in'])
          .maybeSingle();

      return reservation == null;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
