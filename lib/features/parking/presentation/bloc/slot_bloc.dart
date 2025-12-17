import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_parking_slots_usecase.dart';
import '../../domain/usecases/reserve_slot_usecase.dart';
import 'slot_event.dart';
import 'slot_state.dart';

class SlotBloc extends Bloc<SlotEvent, SlotState> {
  final GetParkingSlotsUseCase getParkingSlotsUseCase;
  final ReserveSlotUseCase reserveSlotUseCase;

  SlotBloc({
    required this.getParkingSlotsUseCase,
    required this.reserveSlotUseCase,
  }) : super(const SlotState()) {
    on<FetchParkingSlots>(_onFetchSlots);
    on<SelectSlot>(_onSelectSlot);
    on<ReserveSlot>(_onReserveSlot);
    on<ClearSlotSelection>(_onClearSelection);
  }

  Future<void> _onFetchSlots(
    FetchParkingSlots event,
    Emitter<SlotState> emit,
  ) async {
    emit(state.copyWith(status: SlotBlocStatus.loading));

    final result = await getParkingSlotsUseCase(event.facilityId);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: SlotBlocStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (slots) =>
          emit(state.copyWith(status: SlotBlocStatus.loaded, slots: slots)),
    );
  }

  void _onSelectSlot(SelectSlot event, Emitter<SlotState> emit) {
    final slot = state.slots.firstWhere(
      (s) => s.id == event.slotId,
      orElse: () => state.slots.first,
    );
    emit(state.copyWith(selectedSlot: slot));
  }

  Future<void> _onReserveSlot(
    ReserveSlot event,
    Emitter<SlotState> emit,
  ) async {
    emit(state.copyWith(status: SlotBlocStatus.reserving));

    final result = await reserveSlotUseCase(
      ReserveSlotParams(
        slotId: event.slotId,
        facilityId: event.facilityId,
        userId: event.userId,
        durationMinutes: event.durationMinutes,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: SlotBlocStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (reservation) => emit(
        state.copyWith(
          status: SlotBlocStatus.reserved,
          reservation: reservation,
        ),
      ),
    );
  }

  void _onClearSelection(ClearSlotSelection event, Emitter<SlotState> emit) {
    emit(state.copyWith(clearSelectedSlot: true));
  }
}
