import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../parking/domain/entities/parking_session.dart';
import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserProfile>> getUserProfile(String userId);
  Future<Either<Failure, List<ParkingSession>>> getUserSessions(
    String plateNumber,
  );
  Future<Either<Failure, void>> updateProfile({
    required String userId,
    String? fullName,
    String? avatarUrl,
  });
}
