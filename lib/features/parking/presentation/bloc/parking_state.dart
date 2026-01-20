import 'package:equatable/equatable.dart';
import '../../domain/entities/parking_location.dart';
import '../../domain/entities/parking_slot.dart';

enum ParkingStatus {
  initial,
  loading,
  loaded,
  loadingSpots,
  spotsLoaded,
  error,
}

class ParkingState extends Equatable {
  final ParkingStatus status;
  final List<ParkingLocation> locations;
  final ParkingLocation? selectedLocation;
  final List<ParkingSlot> spots;
  final List<ParkingSlot> searchResults;
  final String? errorMessage;
  final bool isSearching;

  const ParkingState({
    this.status = ParkingStatus.initial,
    this.locations = const [],
    this.selectedLocation,
    this.spots = const [],
    this.searchResults = const [],
    this.errorMessage,
    this.isSearching = false,
  });

  bool get isViewingSpots => selectedLocation != null;

  int get availableCount => spots.where((s) => s.isAvailable).length;
  int get occupiedCount => spots.where((s) => s.isOccupied).length;
  int get reservedCount => spots.where((s) => s.isReserved).length;

  ParkingState copyWith({
    ParkingStatus? status,
    List<ParkingLocation>? locations,
    ParkingLocation? selectedLocation,
    bool clearSelectedLocation = false,
    List<ParkingSlot>? spots,
    List<ParkingSlot>? searchResults,
    String? errorMessage,
    bool? isSearching,
  }) {
    return ParkingState(
      status: status ?? this.status,
      locations: locations ?? this.locations,
      selectedLocation: clearSelectedLocation
          ? null
          : (selectedLocation ?? this.selectedLocation),
      spots: spots ?? this.spots,
      searchResults: searchResults ?? this.searchResults,
      errorMessage: errorMessage ?? this.errorMessage,
      isSearching: isSearching ?? this.isSearching,
    );
  }

  @override
  List<Object?> get props => [
    status,
    locations,
    selectedLocation,
    spots,
    searchResults,
    errorMessage,
    isSearching,
  ];
}
