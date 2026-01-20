import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/vehicle.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../datasources/vehicle_remote_data_source.dart';

class VehicleRepositoryImpl implements VehicleRepository {
  final VehicleRemoteDataSource remoteDataSource;

  VehicleRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Vehicle>>> getVehicles(String userId) async {
    try {
      final vehicles = await remoteDataSource.getVehicles(userId);
      return Right(vehicles);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Vehicle>> getVehicleById(String vehicleId) async {
    try {
      final vehicle = await remoteDataSource.getVehicleById(vehicleId);
      return Right(vehicle);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Vehicle>> addVehicle({
    required String userId,
    required String licensePlate,
    String? vehicleName,
    String? vehicleType,
    String? vehicleColor,
    String? vehicleMake,
    String? vehicleModel,
    bool isDefault = false,
  }) async {
    try {
      final vehicle = await remoteDataSource.addVehicle(
        userId: userId,
        licensePlate: licensePlate,
        vehicleName: vehicleName,
        vehicleType: vehicleType,
        vehicleColor: vehicleColor,
        vehicleMake: vehicleMake,
        vehicleModel: vehicleModel,
        isDefault: isDefault,
      );
      return Right(vehicle);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Vehicle>> updateVehicle({
    required String vehicleId,
    String? licensePlate,
    String? vehicleName,
    String? vehicleType,
    String? vehicleColor,
    String? vehicleMake,
    String? vehicleModel,
    bool? isDefault,
  }) async {
    try {
      final vehicle = await remoteDataSource.updateVehicle(
        vehicleId: vehicleId,
        licensePlate: licensePlate,
        vehicleName: vehicleName,
        vehicleType: vehicleType,
        vehicleColor: vehicleColor,
        vehicleMake: vehicleMake,
        vehicleModel: vehicleModel,
        isDefault: isDefault,
      );
      return Right(vehicle);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteVehicle(String vehicleId) async {
    try {
      await remoteDataSource.deleteVehicle(vehicleId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Vehicle>> setDefaultVehicle({
    required String userId,
    required String vehicleId,
  }) async {
    try {
      final vehicle = await remoteDataSource.setDefaultVehicle(
        userId: userId,
        vehicleId: vehicleId,
      );
      return Right(vehicle);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
