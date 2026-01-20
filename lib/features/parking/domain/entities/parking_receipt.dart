import 'package:equatable/equatable.dart';

class ParkingReceipt extends Equatable {
  final String id;
  final String parkingSessionId;
  final String facilityName;
  final String facilityAddress;
  final String licensePlate;
  final String? slotNumber;
  final DateTime entryTime;
  final DateTime exitTime;
  final double duration; // in hours
  final double ratePerHour;
  final double subtotal;
  final double? tax;
  final double totalAmount;
  final String currency;
  final String paymentMethod;
  final String? transactionId;
  final DateTime createdAt;

  const ParkingReceipt({
    required this.id,
    required this.parkingSessionId,
    required this.facilityName,
    required this.facilityAddress,
    required this.licensePlate,
    this.slotNumber,
    required this.entryTime,
    required this.exitTime,
    required this.duration,
    required this.ratePerHour,
    required this.subtotal,
    this.tax,
    required this.totalAmount,
    this.currency = 'LKR',
    required this.paymentMethod,
    this.transactionId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    parkingSessionId,
    facilityName,
    facilityAddress,
    licensePlate,
    slotNumber,
    entryTime,
    exitTime,
    duration,
    ratePerHour,
    subtotal,
    tax,
    totalAmount,
    currency,
    paymentMethod,
    transactionId,
    createdAt,
  ];
}
