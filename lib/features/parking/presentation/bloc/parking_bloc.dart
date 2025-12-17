import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_parking_facilities_usecase.dart';
import '../../domain/usecases/search_facilities_usecase.dart';
import '../../domain/usecases/get_recent_facilities_usecase.dart';
import 'parking_event.dart';
import 'parking_state.dart';

class ParkingBloc extends Bloc<ParkingEvent, ParkingState> {
  final GetParkingFacilitiesUseCase getParkingFacilitiesUseCase;
  final SearchFacilitiesUseCase searchFacilitiesUseCase;
  final GetRecentFacilitiesUseCase getRecentFacilitiesUseCase;

  ParkingBloc({
    required this.getParkingFacilitiesUseCase,
    required this.searchFacilitiesUseCase,
    required this.getRecentFacilitiesUseCase,
  }) : super(const ParkingState()) {
    on<FetchParkingFacilities>(_onFetchFacilities);
    on<SearchFacilities>(_onSearchFacilities);
    on<FetchRecentFacilities>(_onFetchRecentFacilities);
    on<ClearSearch>(_onClearSearch);
  }

  Future<void> _onFetchFacilities(
    FetchParkingFacilities event,
    Emitter<ParkingState> emit,
  ) async {
    emit(state.copyWith(status: ParkingStatus.loading));

    final result = await getParkingFacilitiesUseCase(const NoParams());

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ParkingStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (facilities) => emit(
        state.copyWith(status: ParkingStatus.loaded, facilities: facilities),
      ),
    );
  }

  Future<void> _onSearchFacilities(
    SearchFacilities event,
    Emitter<ParkingState> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(state.copyWith(isSearching: false, searchResults: []));
      return;
    }

    emit(state.copyWith(isSearching: true));

    final result = await searchFacilitiesUseCase(event.query);

    result.fold(
      (failure) => emit(
        state.copyWith(isSearching: false, errorMessage: failure.message),
      ),
      (facilities) =>
          emit(state.copyWith(isSearching: false, searchResults: facilities)),
    );
  }

  Future<void> _onFetchRecentFacilities(
    FetchRecentFacilities event,
    Emitter<ParkingState> emit,
  ) async {
    final result = await getRecentFacilitiesUseCase(event.userId);

    result.fold(
      (failure) => null, // Silently fail for recent facilities
      (facilities) => emit(state.copyWith(recentFacilities: facilities)),
    );
  }

  void _onClearSearch(ClearSearch event, Emitter<ParkingState> emit) {
    emit(state.copyWith(isSearching: false, searchResults: []));
  }
}
