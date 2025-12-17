import 'package:equatable/equatable.dart';

abstract class SlotEvent extends Equatable {
  const SlotEvent();

  @override
  List<Object?> get props => [];
}

class FetchParkingSlots extends SlotEvent {
  final String facilityId;

  const FetchParkingSlots(this.facilityId);

  @override
  List<Object?> get props => [facilityId];
}

class SelectSlot extends SlotEvent {
  final String slotId;

  const SelectSlot(this.slotId);

  @override
  List<Object?> get props => [slotId];
}

class ReserveSlot extends SlotEvent {
  final String slotId;
  final String facilityId;
  final String userId;
  final int durationMinutes;

  const ReserveSlot({
    required this.slotId,
    required this.facilityId,
    required this.userId,
    required this.durationMinutes,
  });

  @override
  List<Object?> get props => [slotId, facilityId, userId, durationMinutes];
}

class ClearSlotSelection extends SlotEvent {
  const ClearSlotSelection();
}
