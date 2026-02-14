import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/user_helpers.dart';
import '../../../history/data/models/parking_session_model.dart';
import '../models/user_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getUserProfile(String userId);
  Future<List<ParkingSessionModel>> getUserSessions(String plateNumber);
  Future<void> updateProfile({
    required String userId,
    String? fullName,
    String? avatarUrl,
  });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final SupabaseClient supabaseClient;

  ProfileRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<UserProfileModel> getUserProfile(String userId) async {
    try {
      // Get current auth user data
      final authUser = supabaseClient.auth.currentUser;
      if (authUser == null) {
        throw ServerException('User not authenticated');
      }

      final userRecord = await getOrCreateUserRecord(
        supabaseClient,
        authUserId: userId,
        email: authUser.email,
        fullName: authUser.userMetadata?['full_name'] as String?,
        profileImage: authUser.userMetadata?['avatar_url'] as String?,
      );
      final dbUserId = (userRecord['id'] as num).toInt();

      final profileData = {
        'id': authUser.id,
        'email': userRecord['email'] ?? authUser.email ?? '',
        'full_name': userRecord['full_name'],
        'avatar_url': userRecord['profile_image'],
        'created_at': userRecord['created_at'] ?? authUser.createdAt,
      };

      // Get session stats from parking_sessions
      int totalSessions = 0;
      int activeSessions = 0;
      try {
        final vehiclesResponse = await supabaseClient
            .from('vehicles')
            .select('id')
            .eq('user_id', dbUserId);
        final vehicleIds = (vehiclesResponse as List)
            .map((v) => v['id'])
            .where((id) => id != null)
            .toList();

        if (vehicleIds.isNotEmpty) {
          final sessionsResponse = await supabaseClient
              .from('parking_sessions')
              .select('id, exit_time')
              .inFilter('vehicle_id', vehicleIds);

          final sessions = sessionsResponse as List;
          totalSessions = sessions.length;
          activeSessions = sessions.where((s) => s['exit_time'] == null).length;
        }
      } catch (e) {
        // Ignore if parking_sessions doesn't exist
      }

      return UserProfileModel.fromJson({
        ...profileData,
        'total_reservations': totalSessions,
        'active_reservations': activeSessions,
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ParkingSessionModel>> getUserSessions(String plateNumber) async {
    try {
      final response = await supabaseClient
          .from('parking_sessions')
          .select()
          .eq('plate_number', plateNumber)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => ParkingSessionModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> updateProfile({
    required String userId,
    String? fullName,
    String? avatarUrl,
  }) async {
    try {
      // Update user metadata in auth
      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      if (updates.isNotEmpty) {
        await supabaseClient.auth.updateUser(UserAttributes(data: updates));
        await supabaseClient
            .from('users')
            .update({
              if (fullName != null) 'full_name': fullName,
              if (avatarUrl != null) 'profile_image': avatarUrl,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('auth_user_id', userId);
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
