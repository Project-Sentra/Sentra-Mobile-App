import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/parking_facility_model.dart';
import '../models/parking_slot_model.dart';
import '../models/reservation_model.dart';

abstract class ParkingRemoteDataSource {
  Future<List<ParkingFacilityModel>> getParkingFacilities();
  Future<ParkingFacilityModel> getParkingFacilityById(String id);
  Future<List<ParkingFacilityModel>> searchFacilities(String query);
  Future<List<ParkingFacilityModel>> getRecentFacilities(String userId);
  Future<List<ParkingSlotModel>> getParkingSlots(String facilityId);
  Future<ParkingSlotModel> getParkingSlotById(String slotId);
  Future<ReservationModel> reserveSlot({
    required String slotId,
    required String facilityId,
    required String userId,
    required int durationMinutes,
  });
  Future<void> cancelReservation(String reservationId);
  Future<void> addToRecentFacilities({
    required String userId,
    required String facilityId,
  });
}

class ParkingRemoteDataSourceImpl implements ParkingRemoteDataSource {
  final SupabaseClient supabaseClient;

  ParkingRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<List<ParkingFacilityModel>> getParkingFacilities() async {
    try {
      final response = await supabaseClient
          .from('parking_facilities')
          .select()
          .order('name');

      return (response as List)
          .map((json) => ParkingFacilityModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ParkingFacilityModel> getParkingFacilityById(String id) async {
    try {
      final response = await supabaseClient
          .from('parking_facilities')
          .select()
          .eq('id', id)
          .single();

      return ParkingFacilityModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ParkingFacilityModel>> searchFacilities(String query) async {
    try {
      final response = await supabaseClient
          .from('parking_facilities')
          .select()
          .ilike('name', '%$query%')
          .order('name');

      return (response as List)
          .map((json) => ParkingFacilityModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ParkingFacilityModel>> getRecentFacilities(String userId) async {
    try {
      final response = await supabaseClient
          .from('recent_facilities')
          .select('parking_facilities(*)')
          .eq('user_id', userId)
          .order('visited_at', ascending: false)
          .limit(10);

      return (response as List)
          .map(
            (json) => ParkingFacilityModel.fromJson(json['parking_facilities']),
          )
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ParkingSlotModel>> getParkingSlots(String facilityId) async {
    try {
      final response = await supabaseClient
          .from('parking_slots')
          .select()
          .eq('facility_id', facilityId)
          .order('slot_number');

      return (response as List)
          .map((json) => ParkingSlotModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ParkingSlotModel> getParkingSlotById(String slotId) async {
    try {
      final response = await supabaseClient
          .from('parking_slots')
          .select()
          .eq('id', slotId)
          .single();

      return ParkingSlotModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ReservationModel> reserveSlot({
    required String slotId,
    required String facilityId,
    required String userId,
    required int durationMinutes,
  }) async {
    try {
      final now = DateTime.now();
      final endTime = now.add(Duration(minutes: durationMinutes));

      // Get slot and facility info
      final slot = await getParkingSlotById(slotId);
      final facility = await getParkingFacilityById(facilityId);

      // Calculate total price
      final hours = durationMinutes / 60;
      final totalPrice = (facility.pricePerHour ?? 0) * hours;

      // Create reservation
      final response = await supabaseClient
          .from('reservations')
          .insert({
            'slot_id': slotId,
            'facility_id': facilityId,
            'user_id': userId,
            'slot_number': slot.slotNumber,
            'facility_name': facility.name,
            'start_time': now.toIso8601String(),
            'end_time': endTime.toIso8601String(),
            'total_price': totalPrice,
            'status': 'active',
          })
          .select()
          .single();

      // Update slot status
      await supabaseClient
          .from('parking_slots')
          .update({
            'status': 'reserved',
            'reserved_by': userId,
            'reserved_until': endTime.toIso8601String(),
          })
          .eq('id', slotId);

      // Update facility available slots
      await supabaseClient
          .from('parking_facilities')
          .update({
            'available_slots': facility.availableSlots - 1,
            'reserved_slots': facility.reservedSlots + 1,
          })
          .eq('id', facilityId);

      return ReservationModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> cancelReservation(String reservationId) async {
    try {
      // Get reservation
      final reservation = await supabaseClient
          .from('reservations')
          .select()
          .eq('id', reservationId)
          .single();

      // Update slot status
      await supabaseClient
          .from('parking_slots')
          .update({
            'status': 'available',
            'reserved_by': null,
            'reserved_until': null,
          })
          .eq('id', reservation['slot_id']);

      // Update facility
      final facility = await getParkingFacilityById(reservation['facility_id']);
      await supabaseClient
          .from('parking_facilities')
          .update({
            'available_slots': facility.availableSlots + 1,
            'reserved_slots': facility.reservedSlots - 1,
          })
          .eq('id', reservation['facility_id']);

      // Update reservation status
      await supabaseClient
          .from('reservations')
          .update({'status': 'cancelled'})
          .eq('id', reservationId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> addToRecentFacilities({
    required String userId,
    required String facilityId,
  }) async {
    try {
      await supabaseClient.from('recent_facilities').upsert({
        'user_id': userId,
        'facility_id': facilityId,
        'visited_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id,facility_id');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
