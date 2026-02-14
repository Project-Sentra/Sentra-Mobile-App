import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/user_helpers.dart';
import '../models/vehicle_model.dart';
import 'vehicle_remote_data_source.dart';

class VehicleRemoteDataSourceImpl implements VehicleRemoteDataSource {
  final SupabaseClient supabaseClient;

  VehicleRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<VehicleModel>> getVehicles(String userId) async {
    try {
      final dbUserId = await getUserIdFromAuth(supabaseClient, userId);
      final response = await supabaseClient
          .from('vehicles')
          .select()
          .eq('user_id', dbUserId)
          .eq('is_active', true)
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
      final parsedId = int.tryParse(vehicleId) ?? vehicleId;
      final response = await supabaseClient
          .from('vehicles')
          .select()
          .eq('id', parsedId)
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
      final dbUserId = await getUserIdFromAuth(supabaseClient, userId);

      final response = await supabaseClient
          .from('vehicles')
          .insert({
            'user_id': dbUserId,
            'plate_number': licensePlate.toUpperCase(),
            'vehicle_type': vehicleType,
            'color': vehicleColor,
            'make': vehicleMake,
            'model': vehicleModel,
            'is_active': true,
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
      final parsedId = int.tryParse(vehicleId) ?? vehicleId;
      final updateData = <String, dynamic>{};

      if (licensePlate != null) {
        updateData['plate_number'] = licensePlate.toUpperCase();
      }
      if (vehicleType != null) updateData['vehicle_type'] = vehicleType;
      if (vehicleColor != null) updateData['color'] = vehicleColor;
      if (vehicleMake != null) updateData['make'] = vehicleMake;
      if (vehicleModel != null) updateData['model'] = vehicleModel;

      final response = await supabaseClient
          .from('vehicles')
          .update(updateData)
          .eq('id', parsedId)
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
      final parsedId = int.tryParse(vehicleId) ?? vehicleId;
      await supabaseClient.from('vehicles').delete().eq('id', parsedId);
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
      final parsedId = int.tryParse(vehicleId) ?? vehicleId;
      final response = await supabaseClient
          .from('vehicles')
          .select()
          .eq('id', parsedId)
          .single();
      return VehicleModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
