import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../parking/data/models/reservation_model.dart';
import '../models/user_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getUserProfile(String userId);
  Future<List<ReservationModel>> getUserReservations(String userId);
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
      final profileResponse = await supabaseClient
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      // Get reservation stats
      final reservationsResponse = await supabaseClient
          .from('reservations')
          .select('id, status')
          .eq('user_id', userId);

      final reservations = reservationsResponse as List;
      final totalReservations = reservations.length;
      final activeReservations = reservations
          .where((r) => r['status'] == 'active')
          .length;

      return UserProfileModel.fromJson({
        ...profileResponse,
        'total_reservations': totalReservations,
        'active_reservations': activeReservations,
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

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
  Future<void> updateProfile({
    required String userId,
    String? fullName,
    String? avatarUrl,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      if (updates.isNotEmpty) {
        await supabaseClient
            .from('profiles')
            .update(updates)
            .eq('id', userId);
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
