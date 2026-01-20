import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/vehicle_model.dart';
import 'vehicle_remote_data_source.dart';

class VehicleRemoteDataSourceImpl implements VehicleRemoteDataSource {
  final SupabaseClient supabaseClient;

  VehicleRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<VehicleModel>> getVehicles(String userId) async {
    try {
      final response = await supabaseClient
          .from('vehicles')
          .select()
          .eq('user_id', userId)
          .order('is_default', ascending: false)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => VehicleModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<VehicleModel> getVehicleById(String vehicleId) async {
    try {
      final response = await supabaseClient
          .from('vehicles')
          .select()
          .eq('id', vehicleId)
          .single();

      return VehicleModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<VehicleModel> addVehicle({
    required String userId,
    required String licensePlate,
    String? vehicleName,
    String? vehicleType,
    String? vehicleColor,
    String? vehicleMake,
    String? vehicleModel,
    bool isDefault = false,
  }) async {
    try {
      // If this is the default vehicle, unset others first
      if (isDefault) {
        await supabaseClient
            .from('vehicles')
            .update({'is_default': false})
            .eq('user_id', userId);
      }

      final response = await supabaseClient
          .from('vehicles')
          .insert({
            'user_id': userId,
            'license_plate': licensePlate.toUpperCase(),
            'vehicle_name': vehicleName,
            'vehicle_type': vehicleType,
            'vehicle_color': vehicleColor,
            'vehicle_make': vehicleMake,
            'vehicle_model': vehicleModel,
            'is_default': isDefault,
          })
          .select()
          .single();

      return VehicleModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<VehicleModel> updateVehicle({
    required String vehicleId,
    String? licensePlate,
    String? vehicleName,
    String? vehicleType,
    String? vehicleColor,
    String? vehicleMake,
    String? vehicleModel,
    bool? isDefault,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (licensePlate != null) {
        updateData['license_plate'] = licensePlate.toUpperCase();
      }
      if (vehicleName != null) updateData['vehicle_name'] = vehicleName;
      if (vehicleType != null) updateData['vehicle_type'] = vehicleType;
      if (vehicleColor != null) updateData['vehicle_color'] = vehicleColor;
      if (vehicleMake != null) updateData['vehicle_make'] = vehicleMake;
      if (vehicleModel != null) updateData['vehicle_model'] = vehicleModel;
      if (isDefault != null) updateData['is_default'] = isDefault;

      final response = await supabaseClient
          .from('vehicles')
          .update(updateData)
          .eq('id', vehicleId)
          .select()
          .single();

      return VehicleModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteVehicle(String vehicleId) async {
    try {
      await supabaseClient.from('vehicles').delete().eq('id', vehicleId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<VehicleModel> setDefaultVehicle({
    required String userId,
    required String vehicleId,
  }) async {
    try {
      // Unset all other defaults for this user
      await supabaseClient
          .from('vehicles')
          .update({'is_default': false})
          .eq('user_id', userId);

      // Set this vehicle as default
      final response = await supabaseClient
          .from('vehicles')
          .update({
            'is_default': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', vehicleId)
          .select()
          .single();

      return VehicleModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
