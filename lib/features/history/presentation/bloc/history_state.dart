import 'package:equatable/equatable.dart';
import '../../../parking/domain/entities/parking_session.dart';
import '../../../parking/domain/entities/parking_receipt.dart';
import '../../../parking/domain/entities/reservation.dart';

enum HistoryStatus { initial, loading, loaded, error }

class HistoryState extends Equatable {
  final HistoryStatus status;
  final bool isLoadingActive;
  final bool isLoadingHistory;
  final List<ParkingSession> parkingHistory;
  final List<ParkingSession> activeSessions;
  final List<Reservation> reservations;
  final List<Reservation> activeReservations;
  final List<ParkingReceipt> receipts;
  final ParkingReceipt? selectedReceipt;
  final String? errorMessage;

  const HistoryState({
    this.status = HistoryStatus.initial,
    this.isLoadingActive = false,
    this.isLoadingHistory = false,
    this.parkingHistory = const [],
    this.activeSessions = const [],
    this.reservations = const [],
    this.activeReservations = const [],
    this.receipts = const [],
    this.selectedReceipt,
    this.errorMessage,
  });

  HistoryState copyWith({
    HistoryStatus? status,
    bool? isLoadingActive,
    bool? isLoadingHistory,
    List<ParkingSession>? parkingHistory,
    List<ParkingSession>? activeSessions,
    List<Reservation>? reservations,
    List<Reservation>? activeReservations,
    List<ParkingReceipt>? receipts,
    ParkingReceipt? selectedReceipt,
    String? errorMessage,
  }) {
    return HistoryState(
      status: status ?? this.status,
      isLoadingActive: isLoadingActive ?? this.isLoadingActive,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      parkingHistory: parkingHistory ?? this.parkingHistory,
      activeSessions: activeSessions ?? this.activeSessions,
      reservations: reservations ?? this.reservations,
      activeReservations: activeReservations ?? this.activeReservations,
      receipts: receipts ?? this.receipts,
      selectedReceipt: selectedReceipt ?? this.selectedReceipt,
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
    reservations,
    activeReservations,
    receipts,
    selectedReceipt,
    errorMessage,
  ];
}
