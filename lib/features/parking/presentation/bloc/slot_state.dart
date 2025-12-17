import 'package:equatable/equatable.dart';
import '../../domain/entities/parking_slot.dart';
import '../../domain/entities/reservation.dart';

enum SlotBlocStatus { initial, loading, loaded, reserving, reserved, error }

class SlotState extends Equatable {
  final SlotBlocStatus status;
  final List<ParkingSlot> slots;
  final ParkingSlot? selectedSlot;
  final Reservation? reservation;
  final String? errorMessage;

  const SlotState({
    this.status = SlotBlocStatus.initial,
    this.slots = const [],
    this.selectedSlot,
    this.reservation,
    this.errorMessage,
  });

  SlotState copyWith({
    SlotBlocStatus? status,
    List<ParkingSlot>? slots,
    ParkingSlot? selectedSlot,
    Reservation? reservation,
    String? errorMessage,
    bool clearSelectedSlot = false,
  }) {
    return SlotState(
      status: status ?? this.status,
      slots: slots ?? this.slots,
      selectedSlot: clearSelectedSlot
          ? null
          : (selectedSlot ?? this.selectedSlot),
      reservation: reservation ?? this.reservation,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    slots,
    selectedSlot,
    reservation,
    errorMessage,
  ];
}
