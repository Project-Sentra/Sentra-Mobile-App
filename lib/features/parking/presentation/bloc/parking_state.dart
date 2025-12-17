import 'package:equatable/equatable.dart';
import '../../domain/entities/parking_facility.dart';

enum ParkingStatus { initial, loading, loaded, error }

class ParkingState extends Equatable {
  final ParkingStatus status;
  final List<ParkingFacility> facilities;
  final List<ParkingFacility> recentFacilities;
  final List<ParkingFacility> searchResults;
  final String? errorMessage;
  final bool isSearching;

  const ParkingState({
    this.status = ParkingStatus.initial,
    this.facilities = const [],
    this.recentFacilities = const [],
    this.searchResults = const [],
    this.errorMessage,
    this.isSearching = false,
  });

  ParkingState copyWith({
    ParkingStatus? status,
    List<ParkingFacility>? facilities,
    List<ParkingFacility>? recentFacilities,
    List<ParkingFacility>? searchResults,
    String? errorMessage,
    bool? isSearching,
  }) {
    return ParkingState(
      status: status ?? this.status,
      facilities: facilities ?? this.facilities,
      recentFacilities: recentFacilities ?? this.recentFacilities,
      searchResults: searchResults ?? this.searchResults,
      errorMessage: errorMessage ?? this.errorMessage,
      isSearching: isSearching ?? this.isSearching,
    );
  }

  @override
  List<Object?> get props => [
    status,
    facilities,
    recentFacilities,
    searchResults,
    errorMessage,
    isSearching,
  ];
}
