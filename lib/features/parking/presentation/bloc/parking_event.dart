import 'package:equatable/equatable.dart';
import '../../domain/entities/parking_location.dart';

abstract class ParkingEvent extends Equatable {
  const ParkingEvent();

  @override
  List<Object?> get props => [];
}

class FetchParkingLocations extends ParkingEvent {
  const FetchParkingLocations();
}

class FetchSpotsByLocation extends ParkingEvent {
  final int locationId;

  const FetchSpotsByLocation(this.locationId);

  @override
  List<Object?> get props => [locationId];
}

class SelectLocation extends ParkingEvent {
  final ParkingLocation location;

  const SelectLocation(this.location);

  @override
  List<Object?> get props => [location];
}

class SearchSpots extends ParkingEvent {
  final String query;

  const SearchSpots(this.query);

  @override
  List<Object?> get props => [query];
}

class ClearSearch extends ParkingEvent {
  const ClearSearch();
}

class BackToLocations extends ParkingEvent {
  const BackToLocations();
}
