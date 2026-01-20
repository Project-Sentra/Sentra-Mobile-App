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
      // Try to get from parking_locations table
      try {
        final response = await supabaseClient
            .from('parking_locations')
            .select()
            .eq('is_active', true)
            .order('name');

        final locations = (response as List)
            .map((json) => ParkingLocationModel.fromJson(json))
            .toList();

        // Get slot counts for each location
        return await _enrichLocationsWithSlotCounts(locations);
      } catch (e) {
        // If parking_locations doesn't exist, create a default location from spots
        return [await _createDefaultLocation()];
      }
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
        .select('spot_id')
        .eq('status', 'active');

    final reservedSpotIds = (activeReservations as List)
        .map((r) => r['spot_id'])
        .toSet();

    for (final location in locations) {
      try {
        final spotsResponse = await supabaseClient
            .from('parking_spots')
            .select('id, is_occupied')
            .eq('location_id', location.id);

        final spots = spotsResponse as List;
        final totalSlots = spots.length;
        // Count spots that are either occupied OR have active reservations
        final availableSlots = spots
            .where(
              (s) =>
                  s['is_occupied'] == false &&
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

  Future<ParkingLocationModel> _createDefaultLocation() async {
    // Create a virtual location from existing spots
    final spotsResponse = await supabaseClient
        .from('parking_spots')
        .select('id, is_occupied');

    // Get active reservations
    final activeReservations = await supabaseClient
        .from('reservations')
        .select('spot_id')
        .eq('status', 'active');

    final reservedSpotIds = (activeReservations as List)
        .map((r) => r['spot_id'])
        .toSet();

    final spots = spotsResponse as List;
    final totalSlots = spots.length;
    final availableSlots = spots
        .where(
          (s) =>
              s['is_occupied'] == false && !reservedSpotIds.contains(s['id']),
        )
        .length;

    return ParkingLocationModel(
      id: 0,
      name: 'Main Parking',
      address: 'Default Location',
      pricePerHour: 100,
      currency: 'LKR',
      isActive: true,
      totalSlots: totalSlots,
      availableSlots: availableSlots,
      occupiedSlots: totalSlots - availableSlots,
    );
  }

  @override
  Future<ParkingLocationModel> getParkingLocationById(int id) async {
    try {
      if (id == 0) {
        return _createDefaultLocation();
      }

      final response = await supabaseClient
          .from('parking_locations')
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
          .from('parking_locations')
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
            .order('spot_name');
      } else {
        response = await supabaseClient
            .from('parking_spots')
            .select()
            .eq('location_id', locationId)
            .order('spot_name');
      }

      // Get active reservations to mark spots as reserved
      final activeReservations = await supabaseClient
          .from('reservations')
          .select('spot_id')
          .eq('status', 'active');

      final reservedSpotIds = (activeReservations as List)
          .map((r) => r['spot_id'])
          .toSet();

      return response.map((json) {
        final spotId = json['id'];
        final isReserved = reservedSpotIds.contains(spotId);

        // If spot is reserved, mark it as occupied
        if (isReserved) {
          json['is_occupied'] = true;
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
            .order('spot_name');
      } else {
        response = await supabaseClient
            .from('parking_spots')
            .select()
            .eq('location_id', locationId)
            .eq('is_occupied', false)
            .order('spot_name');
      }

      return response.map((json) => ParkingSlotModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
