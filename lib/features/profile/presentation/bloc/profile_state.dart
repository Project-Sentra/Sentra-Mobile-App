import 'package:equatable/equatable.dart';
import '../../../parking/domain/entities/parking_session.dart';
import '../../domain/entities/user_profile.dart';

enum ProfileStatus { initial, loading, loaded, error }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final UserProfile? profile;
  final List<ParkingSession> sessions;
  final String? errorMessage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.sessions = const [],
    this.errorMessage,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    UserProfile? profile,
    List<ParkingSession>? sessions,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      sessions: sessions ?? this.sessions,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, profile, sessions, errorMessage];
}
