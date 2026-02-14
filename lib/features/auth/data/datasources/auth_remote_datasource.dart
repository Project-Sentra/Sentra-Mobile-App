import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../../../../core/utils/user_helpers.dart';

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

      final userRecord = await getOrCreateUserRecord(
        supabaseClient,
        authUserId: response.user!.id,
        email: response.user!.email,
        fullName: response.user!.userMetadata?['full_name'] as String?,
        profileImage: response.user!.userMetadata?['avatar_url'] as String?,
      );

      return UserModel.fromJson({
        'id': response.user!.id,
        'email': userRecord['email'] ?? response.user!.email,
        'full_name':
            userRecord['full_name'] ??
            response.user!.userMetadata?['full_name'],
        'avatar_url': userRecord['profile_image'] ??
            response.user!.userMetadata?['avatar_url'],
        'created_at': userRecord['created_at'] ?? response.user!.createdAt,
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

      final userRecord = await getOrCreateUserRecord(
        supabaseClient,
        authUserId: response.user!.id,
        email: email,
        fullName: fullName,
        profileImage: response.user!.userMetadata?['avatar_url'] as String?,
      );

      return UserModel.fromJson({
        'id': response.user!.id,
        'email': userRecord['email'] ?? email,
        'full_name': userRecord['full_name'] ?? fullName,
        'avatar_url': userRecord['profile_image'],
        'created_at': userRecord['created_at'] ?? DateTime.now().toIso8601String(),
      });
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

      final userRecord = await getOrCreateUserRecord(
        supabaseClient,
        authUserId: user.id,
        email: user.email,
        fullName: user.userMetadata?['full_name'] as String?,
        profileImage: user.userMetadata?['avatar_url'] as String?,
      );

      return UserModel.fromJson({
        'id': user.id,
        'email': userRecord['email'] ?? user.email,
        'full_name':
            userRecord['full_name'] ?? user.userMetadata?['full_name'],
        'avatar_url':
            userRecord['profile_image'] ?? user.userMetadata?['avatar_url'],
        'created_at': userRecord['created_at'] ?? user.createdAt,
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

      final userRecord = await getOrCreateUserRecord(
        supabaseClient,
        authUserId: user.id,
        email: user.email,
        fullName:
            user.userMetadata?['full_name'] as String? ??
            user.userMetadata?['name'] as String?,
        profileImage:
            user.userMetadata?['avatar_url'] as String? ??
            user.userMetadata?['picture'] as String?,
      );

      return UserModel(
        id: user.id,
        email: userRecord['email'] ?? user.email ?? '',
        fullName:
            userRecord['full_name'] as String? ??
            user.userMetadata?['full_name'] as String? ??
            user.userMetadata?['name'] as String?,
        avatarUrl:
            userRecord['profile_image'] as String? ??
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

      final userRecord = await getOrCreateUserRecord(
        supabaseClient,
        authUserId: user.id,
        email: user.email,
        fullName: user.userMetadata?['full_name'] as String?,
      );

      return UserModel(
        id: user.id,
        email: userRecord['email'] ?? user.email ?? '',
        fullName: userRecord['full_name'] as String? ??
            user.userMetadata?['full_name'] as String?,
      );
    } catch (e) {
      throw AuthException(e.toString());
    }
  }
}
