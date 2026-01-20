import 'package:equatable/equatable.dart';

class ParkingSession extends Equatable {
  final int id;
  final String plateNumber;
  final String spotName;
  final DateTime entryTime;
  final DateTime? exitTime;
  final int? durationMinutes;
  final int? amountLkr;
  final DateTime createdAt;

  const ParkingSession({
    required this.id,
    required this.plateNumber,
    required this.spotName,
    required this.entryTime,
    this.exitTime,
    this.durationMinutes,
    this.amountLkr,
    required this.createdAt,
  });

  bool get isActive => exitTime == null;
  bool get isCompleted => exitTime != null;

  String get formattedDuration {
    if (durationMinutes == null) return '-';
    final hours = durationMinutes! ~/ 60;
    final minutes = durationMinutes! % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  String get formattedAmount {
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
    createdAt,
  ];
}
