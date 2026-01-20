import 'package:equatable/equatable.dart';

enum ParkingSessionStatus { active, completed, cancelled }

class ParkingSession extends Equatable {
  final String id;
  final String facilityId;
  final String facilityName;
  final String? slotId;
  final String? slotNumber;
  final String userId;
  final String vehicleId;
  final String licensePlate;
  final DateTime entryTime;
  final DateTime? exitTime;
  final double? duration; // in hours
  final double? totalAmount;
  final String currency;
  final ParkingSessionStatus status;
  final String? paymentId;
  final DateTime createdAt;

  const ParkingSession({
    required this.id,
    required this.facilityId,
    required this.facilityName,
    this.slotId,
    this.slotNumber,
    required this.userId,
    required this.vehicleId,
    required this.licensePlate,
    required this.entryTime,
    this.exitTime,
    this.duration,
    this.totalAmount,
    this.currency = 'LKR',
    required this.status,
    this.paymentId,
    required this.createdAt,
  });

  bool get isActive => status == ParkingSessionStatus.active;
  bool get isCompleted => status == ParkingSessionStatus.completed;

  @override
  List<Object?> get props => [
    id,
    facilityId,
    facilityName,
    slotId,
    slotNumber,
    userId,
    vehicleId,
    licensePlate,
    entryTime,
    exitTime,
    duration,
    totalAmount,
    currency,
    status,
    paymentId,
    createdAt,
  ];

  ParkingSession copyWith({
    String? id,
    String? facilityId,
    String? facilityName,
    String? slotId,
    String? slotNumber,
    String? userId,
    String? vehicleId,
    String? licensePlate,
    DateTime? entryTime,
    DateTime? exitTime,
    double? duration,
    double? totalAmount,
    String? currency,
    ParkingSessionStatus? status,
    String? paymentId,
    DateTime? createdAt,
  }) {
    return ParkingSession(
      id: id ?? this.id,
      facilityId: facilityId ?? this.facilityId,
      facilityName: facilityName ?? this.facilityName,
      slotId: slotId ?? this.slotId,
      slotNumber: slotNumber ?? this.slotNumber,
      userId: userId ?? this.userId,
      vehicleId: vehicleId ?? this.vehicleId,
      licensePlate: licensePlate ?? this.licensePlate,
      entryTime: entryTime ?? this.entryTime,
      exitTime: exitTime ?? this.exitTime,
      duration: duration ?? this.duration,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      paymentId: paymentId ?? this.paymentId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
