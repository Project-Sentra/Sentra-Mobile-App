import '../../domain/entities/parking_slot.dart';

class ParkingSlotModel extends ParkingSlot {
  const ParkingSlotModel({
    required super.id,
    required super.slotName,
    super.locationId,
    super.locationName,
    super.isOccupied,
    super.reservedBy,
    super.reservedUntil,
    super.createdAt,
  });

  factory ParkingSlotModel.fromJson(Map<String, dynamic> json) {
    final reservedUntil = json['reserved_until'] != null
        ? DateTime.parse(json['reserved_until'].toString())
        : null;
    final isReserved = json['is_reserved'] as bool? ?? reservedUntil != null;

    final locationIdValue = json['facility_id'] ?? json['location_id'];
    return ParkingSlotModel(
      id: (json['id'] as num).toInt(),
      slotName: json['spot_name'] as String,
      locationId:
          locationIdValue != null
              ? (locationIdValue as num).toInt()
              : null,
      locationName: json['facility_name'] as String? ??
          json['location_name'] as String?,
      isOccupied: json['is_occupied'] as bool? ?? false,
      reservedBy: json['reserved_by'] as String? ??
          (isReserved ? 'reserved' : null),
      reservedUntil:
          reservedUntil ??
          (isReserved ? DateTime.now().add(const Duration(hours: 1)) : null),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final isReserved = reservedBy != null || reservedUntil != null;
    return {
      'id': id,
      'spot_name': slotName,
      'facility_id': locationId,
      'is_occupied': isOccupied,
      'is_reserved': isReserved,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
