import 'package:equatable/equatable.dart';

abstract class VehicleEvent extends Equatable {
  const VehicleEvent();

  @override
  List<Object?> get props => [];
}

class FetchVehicles extends VehicleEvent {
  final String userId;

  const FetchVehicles(this.userId);

  @override
  List<Object?> get props => [userId];
}

class AddVehicle extends VehicleEvent {
  final String userId;
  final String licensePlate;
  final String? vehicleName;
  final String? vehicleType;
  final String? vehicleColor;
  final String? vehicleMake;
  final String? vehicleModel;
  final bool isDefault;

  const AddVehicle({
    required this.userId,
    required this.licensePlate,
    this.vehicleName,
    this.vehicleType,
    this.vehicleColor,
    this.vehicleMake,
    this.vehicleModel,
    this.isDefault = false,
  });

  @override
  List<Object?> get props => [
    userId,
    licensePlate,
    vehicleName,
    vehicleType,
    vehicleColor,
    vehicleMake,
    vehicleModel,
    isDefault,
  ];
}

class UpdateVehicle extends VehicleEvent {
  final String vehicleId;
  final String? licensePlate;
  final String? vehicleName;
  final String? vehicleType;
  final String? vehicleColor;
  final String? vehicleMake;
  final String? vehicleModel;
  final bool? isDefault;

  const UpdateVehicle({
    required this.vehicleId,
    this.licensePlate,
    this.vehicleName,
    this.vehicleType,
    this.vehicleColor,
    this.vehicleMake,
    this.vehicleModel,
    this.isDefault,
  });

  @override
  List<Object?> get props => [
    vehicleId,
    licensePlate,
    vehicleName,
    vehicleType,
    vehicleColor,
    vehicleMake,
    vehicleModel,
    isDefault,
  ];
}

class DeleteVehicle extends VehicleEvent {
  final String vehicleId;
  final String userId;

  const DeleteVehicle({required this.vehicleId, required this.userId});

  @override
  List<Object?> get props => [vehicleId, userId];
}

class SetDefaultVehicle extends VehicleEvent {
  final String userId;
  final String vehicleId;

  const SetDefaultVehicle({required this.userId, required this.vehicleId});

  @override
  List<Object?> get props => [userId, vehicleId];
}
