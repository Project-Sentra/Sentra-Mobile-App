import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/parking_location_model.dart';
import '../models/parking_slot_model.dart';

abstract class ParkingRemoteDataSource {
  // Locations
  Future<List<ParkingLocationModel>> getParkingLocations();
  Future<ParkingLocationModel> getParkingLocationById(int id);
  Future<List<ParkingLocationModel>> searchLocations(String query);

  // Spots
  Future<List<ParkingSlotModel>> getParkingSpots();
  Future<List<ParkingSlotModel>> getSpotsByLocation(int locationId);
  Future<ParkingSlotModel> getParkingSpotById(int id);
  Future<List<ParkingSlotModel>> searchSpots(String query);
  Future<List<ParkingSlotModel>> getAvailableSpots();
  Future<List<ParkingSlotModel>> getAvailableSpotsByLocation(int locationId);
}

class ParkingRemoteDataSourceImpl implements ParkingRemoteDataSource {
  final SupabaseClient supabaseClient;

  ParkingRemoteDataSourceImpl(this.supabaseClient);

  // ========== LOCATIONS ==========

  @override
  Future<List<ParkingLocationModel>> getParkingLocations() async {
    try {
      final response = await supabaseClient
          .from('facilities')
          .select()
          .eq('is_active', true)
          .order('name');

      final locations = (response as List)
          .map((json) => ParkingLocationModel.fromJson(json))
          .toList();

      // Get slot counts for each location
      return await _enrichLocationsWithSlotCounts(locations);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<List<ParkingLocationModel>> _enrichLocationsWithSlotCounts(
    List<ParkingLocationModel> locations,
  ) async {
    final enrichedLocations = <ParkingLocationModel>[];

    // Get all active reservations to include reserved spots as occupied
    final activeReservations = await supabaseClient
        .from('reservations')
        .select('facility_id, spot_id')
        .inFilter('status', ['pending', 'confirmed', 'checked_in']);

    final reservedByFacility = <int, Set<int>>{};
    for (final reservation in (activeReservations as List)) {
      final facilityId = reservation['facility_id'] as int?;
      final spotId = reservation['spot_id'] as int?;
      if (facilityId == null || spotId == null) {
        continue;
      }
      reservedByFacility
          .putIfAbsent(facilityId, () => <int>{})
          .add(spotId);
    }

    for (final location in locations) {
      try {
        final spotsResponse = await supabaseClient
            .from('parking_spots')
            .select('id, is_occupied, is_reserved')
            .eq('facility_id', location.id)
            .eq('is_active', true);

        final spots = spotsResponse as List;
        final totalSlots = spots.length;
        final reservedSpotIds = reservedByFacility[location.id] ?? <int>{};
        // Count spots that are either occupied OR have active reservations
        final availableSlots = spots
            .where(
              (s) =>
                  s['is_occupied'] == false &&
                  s['is_reserved'] != true &&
                  !reservedSpotIds.contains(s['id']),
            )
            .length;
        final occupiedSlots = totalSlots - availableSlots;

        enrichedLocations.add(
          ParkingLocationModel(
            id: location.id,
            name: location.name,
            address: location.address,
            latitude: location.latitude,
            longitude: location.longitude,
            pricePerHour: location.pricePerHour,
            currency: location.currency,
            imageUrl: location.imageUrl,
            isActive: location.isActive,
            totalSlots: totalSlots,
            availableSlots: availableSlots,
            occupiedSlots: occupiedSlots,
            createdAt: location.createdAt,
          ),
        );
      } catch (e) {
        enrichedLocations.add(location);
      }
    }

    return enrichedLocations;
  }


  @override
  Future<ParkingLocationModel> getParkingLocationById(int id) async {
    try {
      final response = await supabaseClient
          .from('facilities')
          .select()
          .eq('id', id)
          .single();

      final location = ParkingLocationModel.fromJson(response);
      final enriched = await _enrichLocationsWithSlotCounts([location]);
      return enriched.first;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ParkingLocationModel>> searchLocations(String query) async {
    try {
      final response = await supabaseClient
          .from('facilities')
          .select()
          .or('name.ilike.%$query%,address.ilike.%$query%')
          .eq('is_active', true)
          .order('name');

      final locations = (response as List)
          .map((json) => ParkingLocationModel.fromJson(json))
          .toList();

      return await _enrichLocationsWithSlotCounts(locations);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // ========== SPOTS ==========

  @override
  Future<List<ParkingSlotModel>> getParkingSpots() async {
    try {
      final response = await supabaseClient
          .from('parking_spots')
          .select()
          .eq('is_active', true)
          .order('spot_name');

      return (response as List)
          .map((json) => ParkingSlotModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ParkingSlotModel>> getSpotsByLocation(int locationId) async {
    try {
      List<dynamic> response;

      if (locationId == 0) {
        // Default location - get all spots
        response = await supabaseClient
            .from('parking_spots')
            .select()
            .eq('is_active', true)
            .order('spot_name');
      } else {
        response = await supabaseClient
            .from('parking_spots')
            .select()
            .eq('facility_id', locationId)
            .eq('is_active', true)
            .order('spot_name');
      }

      // Get active reservations to mark spots as reserved
      var reservationsQuery = supabaseClient
          .from('reservations')
          .select('spot_id, reserved_end')
          .inFilter('status', ['pending', 'confirmed', 'checked_in']);
      if (locationId != 0) {
        reservationsQuery = reservationsQuery.eq('facility_id', locationId);
      }
      final activeReservations = await reservationsQuery;

      final reservedUntilBySpotId = <int, String?>{};
      for (final reservation in (activeReservations as List)) {
        final spotId = reservation['spot_id'] as int?;
        if (spotId == null) continue;
        reservedUntilBySpotId[spotId] = reservation['reserved_end'] as String?;
      }

      return response.map((json) {
        final spotId = json['id'];
        final reservedUntil = reservedUntilBySpotId[spotId];
        final isReserved =
            reservedUntilBySpotId.containsKey(spotId) ||
            json['is_reserved'] == true;
        if (isReserved) {
          json['is_reserved'] = true;
          json['reserved_by'] = json['reserved_by'] ?? 'reservation';
          if (reservedUntil != null) {
            json['reserved_until'] = reservedUntil;
          }
        }

        return ParkingSlotModel.fromJson(json);
      }).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ParkingSlotModel> getParkingSpotById(int id) async {
    try {
      final response = await supabaseClient
          .from('parking_spots')
          .select()
          .eq('id', id)
          .single();

      return ParkingSlotModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ParkingSlotModel>> searchSpots(String query) async {
    try {
      final response = await supabaseClient
          .from('parking_spots')
          .select()
          .ilike('spot_name', '%$query%')
          .eq('is_active', true)
          .order('spot_name');

      return (response as List)
          .map((json) => ParkingSlotModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ParkingSlotModel>> getAvailableSpots() async {
    try {
      final response = await supabaseClient
          .from('parking_spots')
          .select()
          .eq('is_occupied', false)
          .eq('is_reserved', false)
          .eq('is_active', true)
          .order('spot_name');

      return (response as List)
          .map((json) => ParkingSlotModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ParkingSlotModel>> getAvailableSpotsByLocation(
    int locationId,
  ) async {
    try {
      List<dynamic> response;

      if (locationId == 0) {
        response = await supabaseClient
            .from('parking_spots')
            .select()
            .eq('is_occupied', false)
            .eq('is_reserved', false)
            .eq('is_active', true)
            .order('spot_name');
      } else {
        response = await supabaseClient
            .from('parking_spots')
            .select()
            .eq('facility_id', locationId)
            .eq('is_occupied', false)
            .eq('is_reserved', false)
            .eq('is_active', true)
            .order('spot_name');
      }

      return response.map((json) => ParkingSlotModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
