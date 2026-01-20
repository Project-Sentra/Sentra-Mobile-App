import 'package:equatable/equatable.dart';

enum ReservationStatus { active, completed, cancelled }

class Reservation extends Equatable {
  final String id; // UUID
  final String? slotId; // UUID
  final String? facilityId; // UUID
  final String userId; // UUID
  final String slotNumber;
  final String facilityName;
  final DateTime startTime;
  final DateTime endTime;
  final double? totalPrice;
  final ReservationStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Reservation({
    required this.id,
    this.slotId,
    this.facilityId,
    required this.userId,
    required this.slotNumber,
    required this.facilityName,
    required this.startTime,
    required this.endTime,
    this.totalPrice,
    this.status = ReservationStatus.active,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isActive => status == ReservationStatus.active;
  bool get isCompleted => status == ReservationStatus.completed;
  bool get isCancelled => status == ReservationStatus.cancelled;

  String get formattedPrice => 'LKR ${(totalPrice ?? 0).toStringAsFixed(0)}';

  Duration get duration => endTime.difference(startTime);

  String get formattedDuration {
    final d = duration;
    if (d.inHours > 0) {
      return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    }
    return '${d.inMinutes}m';
  }

  @override
  List<Object?> get props => [
    id,
    slotId,
    facilityId,
    userId,
    slotNumber,
    facilityName,
    startTime,
    endTime,
    totalPrice,
    status,
    createdAt,
    updatedAt,
  ];
}
