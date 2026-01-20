import 'package:equatable/equatable.dart';

abstract class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object?> get props => [];
}

class FetchParkingHistory extends HistoryEvent {
  const FetchParkingHistory();
}

class FetchActiveSessions extends HistoryEvent {
  const FetchActiveSessions();
}
