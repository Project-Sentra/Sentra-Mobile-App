import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_parking_locations_usecase.dart';
import '../../domain/usecases/get_spots_by_location_usecase.dart';
import '../../domain/usecases/search_facilities_usecase.dart';
import 'parking_event.dart';
import 'parking_state.dart';

class ParkingBloc extends Bloc<ParkingEvent, ParkingState> {
  final GetParkingLocationsUseCase getParkingLocationsUseCase;
  final GetSpotsByLocationUseCase getSpotsByLocationUseCase;
  final SearchSpotsUseCase searchSpotsUseCase;

  ParkingBloc({
    required this.getParkingLocationsUseCase,
    required this.getSpotsByLocationUseCase,
    required this.searchSpotsUseCase,
  }) : super(const ParkingState()) {
    on<FetchParkingLocations>(_onFetchLocations);
    on<FetchSpotsByLocation>(_onFetchSpotsByLocation);
    on<SelectLocation>(_onSelectLocation);
    on<SearchSpots>(_onSearchSpots);
    on<ClearSearch>(_onClearSearch);
    on<BackToLocations>(_onBackToLocations);
  }

  Future<void> _onFetchLocations(
    FetchParkingLocations event,
    Emitter<ParkingState> emit,
  ) async {
    emit(state.copyWith(status: ParkingStatus.loading));

    final result = await getParkingLocationsUseCase(const NoParams());

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ParkingStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (locations) => emit(
        state.copyWith(status: ParkingStatus.loaded, locations: locations),
      ),
    );
  }

  Future<void> _onFetchSpotsByLocation(
    FetchSpotsByLocation event,
    Emitter<ParkingState> emit,
  ) async {
    emit(state.copyWith(status: ParkingStatus.loadingSpots));

    final result = await getSpotsByLocationUseCase(event.locationId);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ParkingStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (spots) =>
          emit(state.copyWith(status: ParkingStatus.spotsLoaded, spots: spots)),
    );
  }

  void _onSelectLocation(SelectLocation event, Emitter<ParkingState> emit) {
    emit(state.copyWith(selectedLocation: event.location));
    add(FetchSpotsByLocation(event.location.id));
  }

  Future<void> _onSearchSpots(
    SearchSpots event,
    Emitter<ParkingState> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(state.copyWith(isSearching: false, searchResults: []));
      return;
    }

    emit(state.copyWith(isSearching: true));

    final result = await searchSpotsUseCase(event.query);

    result.fold(
      (failure) => emit(
        state.copyWith(isSearching: false, errorMessage: failure.message),
      ),
      (spots) => emit(state.copyWith(isSearching: false, searchResults: spots)),
    );
  }

  void _onClearSearch(ClearSearch event, Emitter<ParkingState> emit) {
    emit(state.copyWith(isSearching: false, searchResults: []));
  }

  void _onBackToLocations(BackToLocations event, Emitter<ParkingState> emit) {
    emit(
      state.copyWith(
        clearSelectedLocation: true,
        spots: [],
        status: ParkingStatus.loaded,
      ),
    );
  }
}
