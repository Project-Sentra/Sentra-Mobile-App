import 'package:equatable/equatable.dart';

class Vehicle extends Equatable {
  final String id;
  final String userId;
  final String licensePlate;
  final String? vehicleName;
  final String? vehicleType;
  final String? vehicleColor;
  final String? vehicleMake;
  final String? vehicleModel;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Vehicle({
    required this.id,
    required this.userId,
    required this.licensePlate,
    this.vehicleName,
    this.vehicleType,
    this.vehicleColor,
    this.vehicleMake,
    this.vehicleModel,
    this.isDefault = false,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    licensePlate,
    vehicleName,
    vehicleType,
    vehicleColor,
    vehicleMake,
    vehicleModel,
    isDefault,
    createdAt,
    updatedAt,
  ];

  Vehicle copyWith({
    String? id,
    String? userId,
    String? licensePlate,
    String? vehicleName,
    String? vehicleType,
    String? vehicleColor,
    String? vehicleMake,
    String? vehicleModel,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Vehicle(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      licensePlate: licensePlate ?? this.licensePlate,
      vehicleName: vehicleName ?? this.vehicleName,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleColor: vehicleColor ?? this.vehicleColor,
      vehicleMake: vehicleMake ?? this.vehicleMake,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
