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

class FetchUserReservations extends ProfileEvent {
  final String userId;

  const FetchUserReservations(this.userId);

  @override
  List<Object?> get props => [userId];
}

class SignOutRequested extends ProfileEvent {
  const SignOutRequested();
}
