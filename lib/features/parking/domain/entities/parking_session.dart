import 'package:equatable/equatable.dart';

class ParkingSession extends Equatable {
  final int id;
  final String plateNumber;
  final String spotName;
  final DateTime entryTime;
  final DateTime? exitTime;
  final int? durationMinutes;
  final int? amountLkr;
  final String? facilityName;
  final int? facilityId;
  final int? hourlyRate;
  final String? sessionType;
  final DateTime createdAt;

  const ParkingSession({
    required this.id,
    required this.plateNumber,
    required this.spotName,
    required this.entryTime,
    this.exitTime,
    this.durationMinutes,
    this.amountLkr,
    this.facilityName,
    this.facilityId,
    this.hourlyRate,
    this.sessionType,
    required this.createdAt,
  });

  bool get isActive => exitTime == null;
  bool get isCompleted => exitTime != null;

  /// Live duration since entry (for active sessions).
  Duration get liveDuration => isActive
      ? DateTime.now().difference(entryTime)
      : Duration(minutes: durationMinutes ?? 0);

  /// Estimated cost using facility hourly rate (falls back to LKR 100).
  int get estimatedCost {
    if (isCompleted) return amountLkr ?? 0;
    final rate = hourlyRate ?? 100;
    final hours = liveDuration.inMinutes / 60;
    return (hours.ceil() < 1 ? 1 : hours.ceil()) * rate;
  }

  String get formattedDuration {
    final d = isActive ? liveDuration : Duration(minutes: durationMinutes ?? 0);
    final hours = d.inHours;
    final mins = d.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${mins}m';
    }
    return '${mins}m';
  }

  String get formattedAmount {
    if (isActive) return 'LKR $estimatedCost';
    if (amountLkr == null) return '-';
    return 'LKR $amountLkr';
  }

  @override
  List<Object?> get props => [
    id,
    plateNumber,
    spotName,
    entryTime,
    exitTime,
    durationMinutes,
    amountLkr,
    facilityName,
    facilityId,
    hourlyRate,
    sessionType,
    createdAt,
  ];
}
