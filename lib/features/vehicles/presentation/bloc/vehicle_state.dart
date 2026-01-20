import 'package:equatable/equatable.dart';
import '../../domain/entities/vehicle.dart';

enum VehicleStatus {
  initial,
  loading,
  loaded,
  adding,
  added,
  updating,
  updated,
  deleting,
  deleted,
  error,
}

class VehicleState extends Equatable {
  final VehicleStatus status;
  final List<Vehicle> vehicles;
  final Vehicle? selectedVehicle;
  final String? errorMessage;

  const VehicleState({
    this.status = VehicleStatus.initial,
    this.vehicles = const [],
    this.selectedVehicle,
    this.errorMessage,
  });

  VehicleState copyWith({
    VehicleStatus? status,
    List<Vehicle>? vehicles,
    Vehicle? selectedVehicle,
    String? errorMessage,
  }) {
    return VehicleState(
      status: status ?? this.status,
      vehicles: vehicles ?? this.vehicles,
      selectedVehicle: selectedVehicle ?? this.selectedVehicle,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, vehicles, selectedVehicle, errorMessage];
}
