import 'package:supabase_flutter/supabase_flutter.dart';
import '../errors/exceptions.dart';

Future<Map<String, dynamic>> getOrCreateUserRecord(
  SupabaseClient supabaseClient, {
  String? authUserId,
  String? email,
  String? fullName,
  String? profileImage,
  String role = 'user',
}) async {
  final authUser = supabaseClient.auth.currentUser;
  final resolvedAuthId = authUserId ?? authUser?.id;
  if (resolvedAuthId == null) {
    throw const ServerException('User not authenticated');
  }

  // First, try to find by auth_user_id
  final existing = await supabaseClient
      .from('users')
      .select()
      .eq('auth_user_id', resolvedAuthId)
      .maybeSingle();

  if (existing != null) {
    final updates = <String, dynamic>{};
    if (existing['email'] == null && email != null) {
      updates['email'] = email;
    }
    if (existing['full_name'] == null && fullName != null) {
      updates['full_name'] = fullName;
    }
    if (existing['profile_image'] == null && profileImage != null) {
      updates['profile_image'] = profileImage;
    }

    if (updates.isEmpty) {
      return existing;
    }

    final updated = await supabaseClient
        .from('users')
        .update(updates)
        .eq('id', existing['id'])
        .select()
        .single();
    return updated;
  }

  final userEmail = email ?? authUser?.email;
  if (userEmail == null) {
    throw const ServerException('Missing user email');
  }

  // Check if a user with this email already exists (but missing auth_user_id link)
  final existingByEmail = await supabaseClient
      .from('users')
      .select()
      .eq('email', userEmail)
      .maybeSingle();

  if (existingByEmail != null) {
    // Update the existing record to link it with the auth_user_id
    final updated = await supabaseClient
        .from('users')
        .update({
          'auth_user_id': resolvedAuthId,
          if (fullName != null) 'full_name': fullName,
          if (profileImage != null) 'profile_image': profileImage,
        })
        .eq('id', existingByEmail['id'])
        .select()
        .single();
    return updated;
  }

  // No existing record found, create a new one
  final inserted = await supabaseClient
      .from('users')
      .insert({
        'auth_user_id': resolvedAuthId,
        'email': userEmail,
        'full_name': fullName ?? authUser?.userMetadata?['full_name'],
        'profile_image': profileImage ?? authUser?.userMetadata?['avatar_url'],
        'role': role,
      })
      .select()
      .single();

  return inserted;
}

Future<int> getUserIdFromAuth(
  SupabaseClient supabaseClient,
  String authUserId,
) async {
  final record = await getOrCreateUserRecord(
    supabaseClient,
    authUserId: authUserId,
  );
  return (record['id'] as num).toInt();
}
