import '../../domain/entities/parking_location.dart';

class ParkingLocationModel extends ParkingLocation {
  const ParkingLocationModel({
    required super.id,
    required super.name,
    super.address,
    super.latitude,
    super.longitude,
    super.pricePerHour,
    super.currency,
    super.imageUrl,
    super.isActive,
    super.totalSlots,
    super.availableSlots,
    super.occupiedSlots,
    super.createdAt,
  });

  factory ParkingLocationModel.fromJson(Map<String, dynamic> json) {
    return ParkingLocationModel(
      id: json['id'] as int,
      name: json['name'] as String,
      address: json['address'] as String?,
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      pricePerHour: json['price_per_hour'] != null
          ? double.parse(json['price_per_hour'].toString())
          : 100,
      currency: json['currency'] as String? ?? 'LKR',
      imageUrl: json['image_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      totalSlots: json['total_slots'] as int? ?? 0,
      availableSlots: json['available_slots'] as int? ?? 0,
      occupiedSlots: json['occupied_slots'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'price_per_hour': pricePerHour,
      'currency': currency,
      'image_url': imageUrl,
      'is_active': isActive,
      'total_slots': totalSlots,
      'available_slots': availableSlots,
      'occupied_slots': occupiedSlots,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
