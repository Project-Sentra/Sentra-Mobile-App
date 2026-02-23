import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class FetchUserProfile extends ProfileEvent {
  final String userId;

  const FetchUserProfile(this.userId);

  @override
  List<Object?> get props => [userId];
}

class FetchUserSessions extends ProfileEvent {
  final String plateNumber;

  const FetchUserSessions(this.plateNumber);

  @override
  List<Object?> get props => [plateNumber];
}

class UpdateUserProfile extends ProfileEvent {
  final String userId;
  final String? fullName;
  final String? avatarUrl;

  const UpdateUserProfile({
    required this.userId,
    this.fullName,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [userId, fullName, avatarUrl];
}

class SignOutRequested extends ProfileEvent {
  const SignOutRequested();
}
