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
      entryTime: DateTime.parse(json['entry_time'].toString()),
      exitTime: json['exit_time'] != null
          ? DateTime.parse(json['exit_time'].toString())
          : null,
      durationMinutes: json['duration_minutes'] != null
          ? (json['duration_minutes'] as num).toInt()
          : null,
      amountLkr: (json['amount'] as num?)?.toInt() ??
          (json['amount_lkr'] as num?)?.toInt(),
      createdAt: DateTime.parse(json['created_at'].toString()),
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
      'amount': amountLkr,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
