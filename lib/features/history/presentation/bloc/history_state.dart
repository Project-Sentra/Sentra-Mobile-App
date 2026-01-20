import 'package:equatable/equatable.dart';
import '../../../parking/domain/entities/parking_session.dart';

enum HistoryStatus { initial, loading, loaded, error }

class HistoryState extends Equatable {
  final HistoryStatus status;
  final bool isLoadingActive;
  final bool isLoadingHistory;
  final List<ParkingSession> parkingHistory;
  final List<ParkingSession> activeSessions;
  final String? errorMessage;

  const HistoryState({
    this.status = HistoryStatus.initial,
    this.isLoadingActive = false,
    this.isLoadingHistory = false,
    this.parkingHistory = const [],
    this.activeSessions = const [],
    this.errorMessage,
  });

  HistoryState copyWith({
    HistoryStatus? status,
    bool? isLoadingActive,
    bool? isLoadingHistory,
    List<ParkingSession>? parkingHistory,
    List<ParkingSession>? activeSessions,
    String? errorMessage,
  }) {
    return HistoryState(
      status: status ?? this.status,
      isLoadingActive: isLoadingActive ?? this.isLoadingActive,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      parkingHistory: parkingHistory ?? this.parkingHistory,
      activeSessions: activeSessions ?? this.activeSessions,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    isLoadingActive,
    isLoadingHistory,
    parkingHistory,
    activeSessions,
    errorMessage,
  ];
}
