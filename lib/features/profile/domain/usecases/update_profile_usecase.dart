import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileParams extends Equatable {
  final String userId;
  final String? fullName;
  final String? avatarUrl;

  const UpdateProfileParams({
    required this.userId,
    this.fullName,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [userId, fullName, avatarUrl];
}

class UpdateProfileUseCase implements UseCase<void, UpdateProfileParams> {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateProfileParams params) {
    return repository.updateProfile(
      userId: params.userId,
      fullName: params.fullName,
      avatarUrl: params.avatarUrl,
    );
  }
}
