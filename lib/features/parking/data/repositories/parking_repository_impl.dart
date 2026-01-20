import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/parking_location.dart';
import '../../domain/entities/parking_slot.dart';
import '../../domain/repositories/parking_repository.dart';
import '../datasources/parking_remote_datasource.dart';

class ParkingRepositoryImpl implements ParkingRepository {
  final ParkingRemoteDataSource remoteDataSource;

  ParkingRepositoryImpl(this.remoteDataSource);

  // ========== LOCATIONS ==========

  @override
  Future<Either<Failure, List<ParkingLocation>>> getParkingLocations() async {
    try {
      final locations = await remoteDataSource.getParkingLocations();
      return Right(locations);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ParkingLocation>> getParkingLocationById(
    int id,
  ) async {
    try {
      final location = await remoteDataSource.getParkingLocationById(id);
      return Right(location);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ParkingLocation>>> searchLocations(
    String query,
  ) async {
    try {
      final locations = await remoteDataSource.searchLocations(query);
      return Right(locations);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ========== SPOTS ==========

  @override
  Future<Either<Failure, List<ParkingSlot>>> getParkingSpots() async {
    try {
      final spots = await remoteDataSource.getParkingSpots();
      return Right(spots);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ParkingSlot>>> getSpotsByLocation(
    int locationId,
  ) async {
    try {
      final spots = await remoteDataSource.getSpotsByLocation(locationId);
      return Right(spots);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ParkingSlot>> getParkingSpotById(int id) async {
    try {
      final spot = await remoteDataSource.getParkingSpotById(id);
      return Right(spot);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ParkingSlot>>> searchSpots(String query) async {
    try {
      final spots = await remoteDataSource.searchSpots(query);
      return Right(spots);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ParkingSlot>>> getAvailableSpots() async {
    try {
      final spots = await remoteDataSource.getAvailableSpots();
      return Right(spots);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ParkingSlot>>> getAvailableSpotsByLocation(
    int locationId,
  ) async {
    try {
      final spots = await remoteDataSource.getAvailableSpotsByLocation(
        locationId,
      );
      return Right(spots);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
