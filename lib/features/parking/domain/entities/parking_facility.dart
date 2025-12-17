import 'package:equatable/equatable.dart';

class ParkingFacility extends Equatable {
  final String id;
  final String name;
  final String? address;
  final double? pricePerHour;
  final String? currency;
  final String? imageUrl;
  final int totalSlots;
  final int availableSlots;
  final int reservedSlots;
  final double? latitude;
  final double? longitude;
  final DateTime? createdAt;

  const ParkingFacility({
    required this.id,
    required this.name,
    this.address,
    this.pricePerHour,
    this.currency = 'LKR',
    this.imageUrl,
    this.totalSlots = 0,
    this.availableSlots = 0,
    this.reservedSlots = 0,
    this.latitude,
    this.longitude,
    this.createdAt,
  });

  int get occupiedSlots => totalSlots - availableSlots - reservedSlots;

  @override
  List<Object?> get props => [
    id,
    name,
    address,
    pricePerHour,
    currency,
    imageUrl,
    totalSlots,
    availableSlots,
    reservedSlots,
    latitude,
    longitude,
    createdAt,
  ];
}
