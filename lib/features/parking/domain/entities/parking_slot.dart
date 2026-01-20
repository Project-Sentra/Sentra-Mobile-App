import 'package:equatable/equatable.dart';

enum SlotStatus { available, occupied, reserved, disabled }

class ParkingSlot extends Equatable {
  final int id;
  final String slotName;
  final int? locationId;
  final String? locationName;
  final bool isOccupied;
  final String? reservedBy;
  final DateTime? reservedUntil;
  final DateTime? createdAt;

  const ParkingSlot({
    required this.id,
    required this.slotName,
    this.locationId,
    this.locationName,
    this.isOccupied = false,
    this.reservedBy,
    this.reservedUntil,
    this.createdAt,
  });

  SlotStatus get status {
    if (reservedBy != null && reservedUntil != null) {
      if (reservedUntil!.isAfter(DateTime.now())) {
        return SlotStatus.reserved;
      }
    }
    return isOccupied ? SlotStatus.occupied : SlotStatus.available;
  }

  bool get isAvailable => status == SlotStatus.available;
  bool get isReserved => status == SlotStatus.reserved;

  @override
  List<Object?> get props => [
    id,
    slotName,
    locationId,
    locationName,
    isOccupied,
    reservedBy,
    reservedUntil,
    createdAt,
  ];
}
