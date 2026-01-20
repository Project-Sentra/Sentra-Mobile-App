import 'package:equatable/equatable.dart';

class ParkingLocation extends Equatable {
  final int id;
  final String name;
  final String? address;
  final double? latitude;
  final double? longitude;
  final double pricePerHour;
  final String currency;
  final String? imageUrl;
  final bool isActive;
  final int totalSlots;
  final int availableSlots;
  final int occupiedSlots;
  final DateTime? createdAt;

  const ParkingLocation({
    required this.id,
    required this.name,
    this.address,
    this.latitude,
    this.longitude,
    this.pricePerHour = 100,
    this.currency = 'LKR',
    this.imageUrl,
    this.isActive = true,
    this.totalSlots = 0,
    this.availableSlots = 0,
    this.occupiedSlots = 0,
    this.createdAt,
  });

  String get formattedPrice =>
      '$currency ${pricePerHour.toStringAsFixed(0)}/hr';

  double get occupancyRate =>
      totalSlots > 0 ? (occupiedSlots / totalSlots) * 100 : 0;

  @override
  List<Object?> get props => [
    id,
    name,
    address,
    latitude,
    longitude,
    pricePerHour,
    currency,
    imageUrl,
    isActive,
    totalSlots,
    availableSlots,
    occupiedSlots,
    createdAt,
  ];
}
