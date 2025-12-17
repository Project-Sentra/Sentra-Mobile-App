import '../../domain/entities/parking_facility.dart';

class ParkingFacilityModel extends ParkingFacility {
  const ParkingFacilityModel({
    required super.id,
    required super.name,
    super.address,
    super.pricePerHour,
    super.currency,
    super.imageUrl,
    super.totalSlots,
    super.availableSlots,
    super.reservedSlots,
    super.latitude,
    super.longitude,
    super.createdAt,
  });

  factory ParkingFacilityModel.fromJson(Map<String, dynamic> json) {
    return ParkingFacilityModel(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String?,
      pricePerHour: (json['price_per_hour'] as num?)?.toDouble(),
      currency: json['currency'] as String? ?? 'LKR',
      imageUrl: json['image_url'] as String?,
      totalSlots: json['total_slots'] as int? ?? 0,
      availableSlots: json['available_slots'] as int? ?? 0,
      reservedSlots: json['reserved_slots'] as int? ?? 0,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
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
      'price_per_hour': pricePerHour,
      'currency': currency,
      'image_url': imageUrl,
      'total_slots': totalSlots,
      'available_slots': availableSlots,
      'reserved_slots': reservedSlots,
      'latitude': latitude,
      'longitude': longitude,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
