import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../parking/domain/entities/reservation.dart';
import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserProfile>> getUserProfile(String userId);
  Future<Either<Failure, List<Reservation>>> getUserReservations(String userId);
  Future<Either<Failure, void>> updateProfile({
    required String userId,
    String? fullName,
    String? avatarUrl,
  });
}
