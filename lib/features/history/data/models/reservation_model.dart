import '../../../parking/domain/entities/reservation.dart';

class ReservationModel extends Reservation {
  const ReservationModel({
    required super.id,
    required super.slotId,
    required super.facilityId,
    required super.userId,
    required super.slotNumber,
    required super.facilityName,
    required super.startTime,
    required super.endTime,
    super.totalPrice,
    super.status,
    super.createdAt,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      id: json['id'] as String,
      slotId: json['slot_id'] as String,
      facilityId: json['facility_id'] as String,
      userId: json['user_id'] as String,
      slotNumber:
          json['slot_number'] as String? ??
          json['slots']?['slot_number'] as String? ??
          '',
      facilityName:
          json['facility_name'] as String? ??
          json['facilities']?['name'] as String? ??
          '',
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      totalPrice: json['total_price'] != null
          ? (json['total_price'] as num).toDouble()
          : null,
      status: json['status'] as String? ?? 'active',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slot_id': slotId,
      'facility_id': facilityId,
      'user_id': userId,
      'slot_number': slotNumber,
      'facility_name': facilityName,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'total_price': totalPrice,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
