import 'package:equatable/equatable.dart';

abstract class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object?> get props => [];
}

class FetchParkingHistory extends HistoryEvent {
  final String userId;

  const FetchParkingHistory(this.userId);

  @override
  List<Object?> get props => [userId];
}

class FetchActiveSessions extends HistoryEvent {
  final String userId;

  const FetchActiveSessions(this.userId);

  @override
  List<Object?> get props => [userId];
}

class FetchReservationHistory extends HistoryEvent {
  final String userId;

  const FetchReservationHistory(this.userId);

  @override
  List<Object?> get props => [userId];
}

class FetchActiveReservations extends HistoryEvent {
  final String userId;

  const FetchActiveReservations(this.userId);

  @override
  List<Object?> get props => [userId];
}

class FetchReceipts extends HistoryEvent {
  final String userId;

  const FetchReceipts(this.userId);

  @override
  List<Object?> get props => [userId];
}

class FetchReceipt extends HistoryEvent {
  final String sessionId;

  const FetchReceipt(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}
