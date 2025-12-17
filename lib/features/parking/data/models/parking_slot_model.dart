import '../../domain/entities/parking_slot.dart';

class ParkingSlotModel extends ParkingSlot {
  const ParkingSlotModel({
    required super.id,
    required super.facilityId,
    required super.slotNumber,
    super.floor,
    super.section,
    super.status,
    super.reservedBy,
    super.reservedUntil,
    super.createdAt,
  });

  factory ParkingSlotModel.fromJson(Map<String, dynamic> json) {
    return ParkingSlotModel(
      id: json['id'] as String,
      facilityId: json['facility_id'] as String,
      slotNumber: json['slot_number'] as String,
      floor: json['floor'] as String?,
      section: json['section'] as String?,
      status: _parseStatus(json['status'] as String?),
      reservedBy: json['reserved_by'] as String?,
      reservedUntil: json['reserved_until'] != null
          ? DateTime.parse(json['reserved_until'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  static SlotStatus _parseStatus(String? status) {
    switch (status) {
      case 'available':
        return SlotStatus.available;
      case 'occupied':
        return SlotStatus.occupied;
      case 'reserved':
        return SlotStatus.reserved;
      case 'disabled':
        return SlotStatus.disabled;
      default:
        return SlotStatus.available;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'facility_id': facilityId,
      'slot_number': slotNumber,
      'floor': floor,
      'section': section,
      'status': status.name,
      'reserved_by': reservedBy,
      'reserved_until': reservedUntil?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
