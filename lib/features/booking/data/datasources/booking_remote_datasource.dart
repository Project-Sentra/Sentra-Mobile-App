import '../models/reservation_model.dart';

abstract class BookingRemoteDataSource {
  Future<List<ReservationModel>> getUserReservations(String userId);
  Future<List<ReservationModel>> getActiveReservations(String userId);
  Future<ReservationModel> getReservationById(int id);
  Future<ReservationModel> createReservation({
    required String userId,
    String? vehicleId,
    required int locationId,
    required int spotId,
    required String plateNumber,
    required String spotName,
    required String locationName,
    required DateTime startTime,
    DateTime? endTime,
    double bookingFee,
  });
  Future<ReservationModel> cancelReservation(int reservationId);
  Future<bool> isSpotAvailable(int spotId);
}
