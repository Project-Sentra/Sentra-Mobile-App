import 'package:equatable/equatable.dart';
import '../../../parking/domain/entities/reservation.dart';
import '../../domain/entities/user_profile.dart';

enum ProfileStatus {
  initial,
  loading,
  loaded,
  error,
}

class ProfileState extends Equatable {
  final ProfileStatus status;
  final UserProfile? profile;
  final List<Reservation> reservations;
  final String? errorMessage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.reservations = const [],
    this.errorMessage,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    UserProfile? profile,
    List<Reservation>? reservations,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      reservations: reservations ?? this.reservations,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, profile, reservations, errorMessage];
}
