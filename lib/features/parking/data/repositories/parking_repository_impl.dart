import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/parking_facility.dart';
import '../../domain/entities/parking_slot.dart';
import '../../domain/entities/reservation.dart';
import '../../domain/repositories/parking_repository.dart';
import '../datasources/parking_remote_datasource.dart';

class ParkingRepositoryImpl implements ParkingRepository {
  final ParkingRemoteDataSource remoteDataSource;

  ParkingRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<ParkingFacility>>> getParkingFacilities() async {
    try {
      final facilities = await remoteDataSource.getParkingFacilities();
      return Right(facilities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ParkingFacility>> getParkingFacilityById(
    String id,
  ) async {
    try {
      final facility = await remoteDataSource.getParkingFacilityById(id);
      return Right(facility);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ParkingFacility>>> searchFacilities(
    String query,
  ) async {
    try {
      final facilities = await remoteDataSource.searchFacilities(query);
      return Right(facilities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ParkingFacility>>> getRecentFacilities(
    String userId,
  ) async {
    try {
      final facilities = await remoteDataSource.getRecentFacilities(userId);
      return Right(facilities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ParkingSlot>>> getParkingSlots(
    String facilityId,
  ) async {
    try {
      final slots = await remoteDataSource.getParkingSlots(facilityId);
      return Right(slots);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ParkingSlot>> getParkingSlotById(String slotId) async {
    try {
      final slot = await remoteDataSource.getParkingSlotById(slotId);
      return Right(slot);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Reservation>> reserveSlot({
    required String slotId,
    required String facilityId,
    required String userId,
    required int durationMinutes,
  }) async {
    try {
      final reservation = await remoteDataSource.reserveSlot(
        slotId: slotId,
        facilityId: facilityId,
        userId: userId,
        durationMinutes: durationMinutes,
      );
      return Right(reservation);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelReservation(String reservationId) async {
    try {
      await remoteDataSource.cancelReservation(reservationId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addToRecentFacilities({
    required String userId,
    required String facilityId,
  }) async {
    try {
      await remoteDataSource.addToRecentFacilities(
        userId: userId,
        facilityId: facilityId,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
