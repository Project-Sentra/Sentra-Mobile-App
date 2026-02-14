import '../../domain/entities/reservation.dart';

class ReservationModel extends Reservation {
  const ReservationModel({
    required super.id,
    super.slotId,
    super.facilityId,
    required super.userId,
    required super.slotNumber,
    required super.facilityName,
    required super.startTime,
    required super.endTime,
    super.totalPrice,
    super.status,
    required super.createdAt,
    super.updatedAt,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    final facility = json['facilities'] ?? json['facility'];
    final spot = json['parking_spots'] ?? json['spot'];
    final start = json['reserved_start'] ?? json['start_time'];
    final end = json['reserved_end'] ?? json['end_time'];

    final slotNumber = (json['spot_name'] ??
                spot?['spot_name'] ??
                json['slot_number'])
            ?.toString() ??
        '-';
    final facilityName = (json['facility_name'] ??
                facility?['name'] ??
                json['location_name'])
            ?.toString() ??
        '-';

    return ReservationModel(
      id: json['id'].toString(),
      slotId: json['spot_id']?.toString(),
      facilityId: (json['facility_id'] ?? json['location_id'])?.toString(),
      userId: json['user_id'].toString(),
      slotNumber: slotNumber,
      facilityName: facilityName,
      startTime: DateTime.parse(start.toString()),
      endTime: DateTime.parse(end.toString()),
      totalPrice: (json['amount'] as num?)?.toDouble() ??
          (json['booking_fee'] as num?)?.toDouble() ??
          (json['total_price'] as num?)?.toDouble(),
      status: _parseStatus(json['status'] as String?),
      createdAt: DateTime.parse(json['created_at'].toString()),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : null,
    );
  }

  static ReservationStatus _parseStatus(String? status) {
    switch (status) {
      case 'confirmed':
      case 'checked_in':
      case 'pending':
        return ReservationStatus.active;
      case 'completed':
        return ReservationStatus.completed;
      case 'no_show':
      case 'cancelled':
        return ReservationStatus.cancelled;
      default:
        return ReservationStatus.active;
    }
  }

  static String _statusToString(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.completed:
        return 'completed';
      case ReservationStatus.cancelled:
        return 'cancelled';
      case ReservationStatus.active:
        return 'pending';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'spot_id': slotId,
      'facility_id': facilityId,
      'user_id': userId,
      'reserved_start': startTime.toIso8601String(),
      'reserved_end': endTime.toIso8601String(),
      'amount': totalPrice,
      'status': _statusToString(status),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
