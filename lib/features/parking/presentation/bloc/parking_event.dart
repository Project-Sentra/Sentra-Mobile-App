import 'package:equatable/equatable.dart';

abstract class ParkingEvent extends Equatable {
  const ParkingEvent();

  @override
  List<Object?> get props => [];
}

class FetchParkingFacilities extends ParkingEvent {
  const FetchParkingFacilities();
}

class SearchFacilities extends ParkingEvent {
  final String query;

  const SearchFacilities(this.query);

  @override
  List<Object?> get props => [query];
}

class FetchRecentFacilities extends ParkingEvent {
  final String userId;

  const FetchRecentFacilities(this.userId);

  @override
  List<Object?> get props => [userId];
}

class ClearSearch extends ParkingEvent {
  const ClearSearch();
}
