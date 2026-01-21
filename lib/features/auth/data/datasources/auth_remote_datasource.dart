import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signIn({required String email, required String password});

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String fullName,
  });

  Future<void> signOut();

  Future<UserModel?> getCurrentUser();

  Future<UserModel> signInWithGoogle();

  Future<UserModel> signInWithApple();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw const AuthException('Sign in failed');
      }

      // Try to get user profile from profiles table, fallback to auth data
      Map<String, dynamic>? profileData;
      try {
        profileData = await supabaseClient
            .from('profiles')
            .select()
            .eq('id', response.user!.id)
            .maybeSingle();
      } catch (_) {
        // profiles table might not exist, continue with auth data
      }

      return UserModel.fromJson({
        'id': response.user!.id,
        'email': response.user!.email,
        'full_name':
            profileData?['full_name'] ??
            response.user!.userMetadata?['full_name'],
        'avatar_url':
            profileData?['avatar_url'] ??
            response.user!.userMetadata?['avatar_url'],
        'created_at': profileData?['created_at'] ?? response.user!.createdAt,
      });
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      if (response.user == null) {
        throw const AuthException('Sign up failed');
      }

      // Profile is automatically created by database trigger
      // No need to manually insert here

      return UserModel(
        id: response.user!.id,
        email: email,
        fullName: fullName,
        createdAt: DateTime.now(),
      );
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await supabaseClient.auth.signOut();
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) return null;

      // Try to get user profile from profiles table, fallback to auth data
      Map<String, dynamic>? profileData;
      try {
        profileData = await supabaseClient
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();
      } catch (_) {
        // profiles table might not exist, continue with auth data
      }

      return UserModel.fromJson({
        'id': user.id,
        'email': user.email,
        'full_name':
            profileData?['full_name'] ?? user.userMetadata?['full_name'],
        'avatar_url':
            profileData?['avatar_url'] ?? user.userMetadata?['avatar_url'],
        'created_at': profileData?['created_at'] ?? user.createdAt,
      });
    } catch (e) {
      return null;
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final response = await supabaseClient.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.sentra://login-callback/',
      );

      if (!response) {
        throw const AuthException('Google sign in failed');
      }

      // Wait for auth state change
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw const AuthException('Google sign in failed');
      }

      // Upsert profile
      await supabaseClient.from('profiles').upsert({
        'id': user.id,
        'email': user.email,
        'full_name':
            user.userMetadata?['full_name'] ?? user.userMetadata?['name'],
        'avatar_url':
            user.userMetadata?['avatar_url'] ?? user.userMetadata?['picture'],
      });

      return UserModel(
        id: user.id,
        email: user.email ?? '',
        fullName:
            user.userMetadata?['full_name'] as String? ??
            user.userMetadata?['name'] as String?,
        avatarUrl:
            user.userMetadata?['avatar_url'] as String? ??
            user.userMetadata?['picture'] as String?,
      );
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserModel> signInWithApple() async {
    try {
      final response = await supabaseClient.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'io.supabase.sentra://login-callback/',
      );

      if (!response) {
        throw const AuthException('Apple sign in failed');
      }

      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw const AuthException('Apple sign in failed');
      }

      // Upsert profile
      await supabaseClient.from('profiles').upsert({
        'id': user.id,
        'email': user.email,
        'full_name': user.userMetadata?['full_name'],
      });

      return UserModel(
        id: user.id,
        email: user.email ?? '',
        fullName: user.userMetadata?['full_name'] as String?,
      );
    } catch (e) {
      throw AuthException(e.toString());
    }
  }
}
