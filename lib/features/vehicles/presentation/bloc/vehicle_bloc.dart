import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/add_vehicle_usecase.dart';
import '../../domain/usecases/delete_vehicle_usecase.dart';
import '../../domain/usecases/get_vehicles_usecase.dart';
import '../../domain/usecases/update_vehicle_usecase.dart';
import 'vehicle_event.dart';
import 'vehicle_state.dart';

class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
  final GetVehiclesUseCase getVehiclesUseCase;
  final AddVehicleUseCase addVehicleUseCase;
  final UpdateVehicleUseCase updateVehicleUseCase;
  final DeleteVehicleUseCase deleteVehicleUseCase;

  VehicleBloc({
    required this.getVehiclesUseCase,
    required this.addVehicleUseCase,
    required this.updateVehicleUseCase,
    required this.deleteVehicleUseCase,
  }) : super(const VehicleState()) {
    on<FetchVehicles>(_onFetchVehicles);
    on<AddVehicle>(_onAddVehicle);
    on<UpdateVehicle>(_onUpdateVehicle);
    on<DeleteVehicle>(_onDeleteVehicle);
  }

  Future<void> _onFetchVehicles(
    FetchVehicles event,
    Emitter<VehicleState> emit,
  ) async {
    emit(state.copyWith(status: VehicleStatus.loading));

    final result = await getVehiclesUseCase(event.userId);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: VehicleStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (vehicles) => emit(
        state.copyWith(status: VehicleStatus.loaded, vehicles: vehicles),
      ),
    );
  }

  Future<void> _onAddVehicle(
    AddVehicle event,
    Emitter<VehicleState> emit,
  ) async {
    emit(state.copyWith(status: VehicleStatus.adding));

    final result = await addVehicleUseCase(
      AddVehicleParams(
        userId: event.userId,
        licensePlate: event.licensePlate,
        vehicleName: event.vehicleName,
        vehicleType: event.vehicleType,
        vehicleColor: event.vehicleColor,
        vehicleMake: event.vehicleMake,
        vehicleModel: event.vehicleModel,
        isDefault: event.isDefault,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: VehicleStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (vehicle) {
        final updatedVehicles = [...state.vehicles, vehicle];
        emit(
          state.copyWith(
            status: VehicleStatus.added,
            vehicles: updatedVehicles,
          ),
        );
      },
    );
  }

  Future<void> _onUpdateVehicle(
    UpdateVehicle event,
    Emitter<VehicleState> emit,
  ) async {
    emit(state.copyWith(status: VehicleStatus.updating));

    final result = await updateVehicleUseCase(
      UpdateVehicleParams(
        vehicleId: event.vehicleId,
        licensePlate: event.licensePlate,
        vehicleName: event.vehicleName,
        vehicleType: event.vehicleType,
        vehicleColor: event.vehicleColor,
        vehicleMake: event.vehicleMake,
        vehicleModel: event.vehicleModel,
        isDefault: event.isDefault,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: VehicleStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (vehicle) {
        final updatedVehicles = state.vehicles.map((v) {
          if (v.id == vehicle.id) return vehicle;
          // If this vehicle became default, unset others
          if (vehicle.isDefault && v.isDefault) {
            return v.copyWith(isDefault: false);
          }
          return v;
        }).toList();
        emit(
          state.copyWith(
            status: VehicleStatus.updated,
            vehicles: updatedVehicles,
          ),
        );
      },
    );
  }

  Future<void> _onDeleteVehicle(
    DeleteVehicle event,
    Emitter<VehicleState> emit,
  ) async {
    emit(state.copyWith(status: VehicleStatus.deleting));

    final result = await deleteVehicleUseCase(event.vehicleId);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: VehicleStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (_) {
        final updatedVehicles = state.vehicles
            .where((v) => v.id != event.vehicleId)
            .toList();
        emit(
          state.copyWith(
            status: VehicleStatus.deleted,
            vehicles: updatedVehicles,
          ),
        );
      },
    );
  }
}
