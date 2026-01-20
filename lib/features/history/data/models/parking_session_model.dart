import '../../../parking/domain/entities/parking_session.dart';

class ParkingSessionModel extends ParkingSession {
  const ParkingSessionModel({
    required super.id,
    required super.facilityId,
    required super.facilityName,
    super.slotId,
    super.slotNumber,
    required super.userId,
    required super.vehicleId,
    required super.licensePlate,
    required super.entryTime,
    super.exitTime,
    super.duration,
    super.totalAmount,
    super.currency,
    required super.status,
    super.paymentId,
    required super.createdAt,
  });

  factory ParkingSessionModel.fromJson(Map<String, dynamic> json) {
    return ParkingSessionModel(
      id: json['id'] as String,
      facilityId: json['facility_id'] as String,
      facilityName:
          json['facility_name'] as String? ??
          json['facilities']?['name'] as String? ??
          '',
      slotId: json['slot_id'] as String?,
      slotNumber:
          json['slot_number'] as String? ??
          json['slots']?['slot_number'] as String?,
      userId: json['user_id'] as String,
      vehicleId: json['vehicle_id'] as String,
      licensePlate:
          json['license_plate'] as String? ??
          json['vehicles']?['license_plate'] as String? ??
          '',
      entryTime: DateTime.parse(json['entry_time'] as String),
      exitTime: json['exit_time'] != null
          ? DateTime.parse(json['exit_time'] as String)
          : null,
      duration: json['duration'] != null
          ? (json['duration'] as num).toDouble()
          : null,
      totalAmount: json['total_amount'] != null
          ? (json['total_amount'] as num).toDouble()
          : null,
      currency: json['currency'] as String? ?? 'LKR',
      status: _parseStatus(json['status'] as String),
      paymentId: json['payment_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'facility_id': facilityId,
      'facility_name': facilityName,
      'slot_id': slotId,
      'slot_number': slotNumber,
      'user_id': userId,
      'vehicle_id': vehicleId,
      'license_plate': licensePlate,
      'entry_time': entryTime.toIso8601String(),
      'exit_time': exitTime?.toIso8601String(),
      'duration': duration,
      'total_amount': totalAmount,
      'currency': currency,
      'status': _statusToString(status),
      'payment_id': paymentId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static ParkingSessionStatus _parseStatus(String status) {
    switch (status) {
      case 'active':
        return ParkingSessionStatus.active;
      case 'completed':
        return ParkingSessionStatus.completed;
      case 'cancelled':
        return ParkingSessionStatus.cancelled;
      default:
        return ParkingSessionStatus.active;
    }
  }

  static String _statusToString(ParkingSessionStatus status) {
    switch (status) {
      case ParkingSessionStatus.active:
        return 'active';
      case ParkingSessionStatus.completed:
        return 'completed';
      case ParkingSessionStatus.cancelled:
        return 'cancelled';
    }
  }
}
