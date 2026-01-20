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
    return ReservationModel(
      id: json['id'].toString(),
      slotId: json['spot_id']?.toString(),
      facilityId: json['location_id']?.toString(),
      userId: json['user_id'].toString(),
      slotNumber: json['spot_name'] as String,
      facilityName: json['location_name'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      totalPrice: null,
      status: _parseStatus(json['status'] as String?),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  static ReservationStatus _parseStatus(String? status) {
    switch (status) {
      case 'completed':
        return ReservationStatus.completed;
      case 'cancelled':
        return ReservationStatus.cancelled;
      case 'active':
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
        return 'active';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'spot_id': slotId,
      'location_id': facilityId,
      'user_id': userId,
      'spot_name': slotNumber,
      'location_name': facilityName,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'status': _statusToString(status),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
