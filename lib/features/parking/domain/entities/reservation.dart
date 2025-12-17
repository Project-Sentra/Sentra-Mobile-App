import 'package:equatable/equatable.dart';

class Reservation extends Equatable {
  final String id;
  final String slotId;
  final String facilityId;
  final String userId;
  final String slotNumber;
  final String facilityName;
  final DateTime startTime;
  final DateTime endTime;
  final double? totalPrice;
  final String status; // active, completed, cancelled
  final DateTime? createdAt;

  const Reservation({
    required this.id,
    required this.slotId,
    required this.facilityId,
    required this.userId,
    required this.slotNumber,
    required this.facilityName,
    required this.startTime,
    required this.endTime,
    this.totalPrice,
    this.status = 'active',
    this.createdAt,
  });

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
  ];
}
