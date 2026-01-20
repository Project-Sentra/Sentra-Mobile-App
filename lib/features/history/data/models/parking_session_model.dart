import '../../../parking/domain/entities/parking_session.dart';

class ParkingSessionModel extends ParkingSession {
  const ParkingSessionModel({
    required super.id,
    required super.plateNumber,
    required super.spotName,
    required super.entryTime,
    super.exitTime,
    super.durationMinutes,
    super.amountLkr,
    required super.createdAt,
  });

  factory ParkingSessionModel.fromJson(Map<String, dynamic> json) {
    return ParkingSessionModel(
      id: (json['id'] as num).toInt(),
      plateNumber: json['plate_number'] as String,
      spotName: json['spot_name'] as String,
      entryTime: DateTime.parse(json['entry_time'] as String),
      exitTime: json['exit_time'] != null
          ? DateTime.parse(json['exit_time'] as String)
          : null,
      durationMinutes: json['duration_minutes'] != null
          ? (json['duration_minutes'] as num).toInt()
          : null,
      amountLkr: json['amount_lkr'] != null
          ? (json['amount_lkr'] as num).toInt()
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plate_number': plateNumber,
      'spot_name': spotName,
      'entry_time': entryTime.toIso8601String(),
      'exit_time': exitTime?.toIso8601String(),
      'duration_minutes': durationMinutes,
      'amount_lkr': amountLkr,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
