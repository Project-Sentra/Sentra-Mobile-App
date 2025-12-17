import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../../domain/usecases/get_user_reservations_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserProfileUseCase getUserProfileUseCase;
  final GetUserReservationsUseCase getUserReservationsUseCase;

  ProfileBloc({
    required this.getUserProfileUseCase,
    required this.getUserReservationsUseCase,
  }) : super(const ProfileState()) {
    on<FetchUserProfile>(_onFetchProfile);
    on<FetchUserReservations>(_onFetchReservations);
  }

  Future<void> _onFetchProfile(
    FetchUserProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));

    final result = await getUserProfileUseCase(event.userId);

    result.fold(
      (failure) => emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: failure.message,
      )),
      (profile) => emit(state.copyWith(
        status: ProfileStatus.loaded,
        profile: profile,
      )),
    );
  }

  Future<void> _onFetchReservations(
    FetchUserReservations event,
    Emitter<ProfileState> emit,
  ) async {
    final result = await getUserReservationsUseCase(event.userId);

    result.fold(
      (failure) => null, // Silently fail
      (reservations) => emit(state.copyWith(
        reservations: reservations,
      )),
    );
  }
}
