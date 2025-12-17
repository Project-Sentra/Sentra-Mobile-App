import 'package:equatable/equatable.dart';

enum SlotStatus { available, occupied, reserved, disabled }

class ParkingSlot extends Equatable {
  final String id;
  final String facilityId;
  final String slotNumber;
  final String? floor;
  final String? section;
  final SlotStatus status;
  final String? reservedBy;
  final DateTime? reservedUntil;
  final DateTime? createdAt;

  const ParkingSlot({
    required this.id,
    required this.facilityId,
    required this.slotNumber,
    this.floor,
    this.section,
    this.status = SlotStatus.available,
    this.reservedBy,
    this.reservedUntil,
    this.createdAt,
  });

  bool get isAvailable => status == SlotStatus.available;
  bool get isOccupied => status == SlotStatus.occupied;
  bool get isReserved => status == SlotStatus.reserved;

  @override
  List<Object?> get props => [
    id,
    facilityId,
    slotNumber,
    floor,
    section,
    status,
    reservedBy,
    reservedUntil,
    createdAt,
  ];
}
