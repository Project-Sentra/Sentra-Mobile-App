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
    return ParkingSlotModel(
      id: (json['id'] as num).toInt(),
      slotName: json['spot_name'] as String,
      locationId: json['location_id'] as int?,
      locationName: json['location_name'] as String?,
      isOccupied: json['is_occupied'] as bool? ?? false,
      reservedBy: json['reserved_by'] as String?,
      reservedUntil: json['reserved_until'] != null
          ? DateTime.parse(json['reserved_until'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'spot_name': slotName,
      'location_id': locationId,
      'is_occupied': isOccupied,
      'reserved_by': reservedBy,
      'reserved_until': reservedUntil?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
