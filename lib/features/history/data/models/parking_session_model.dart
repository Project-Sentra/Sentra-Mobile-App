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
    super.facilityName,
    super.facilityId,
    super.hourlyRate,
    super.sessionType,
    required super.createdAt,
  });

  factory ParkingSessionModel.fromJson(Map<String, dynamic> json) {
    // Facility data may come from a join as nested object
    final facilityData = json['facilities'] as Map<String, dynamic>?;

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
      amountLkr:
          (json['amount'] as num?)?.toInt() ??
          (json['amount_lkr'] as num?)?.toInt(),
      facilityId: (json['facility_id'] as num?)?.toInt(),
      facilityName:
          facilityData?['name'] as String? ?? json['facility_name'] as String?,
      hourlyRate:
          (facilityData?['hourly_rate'] as num?)?.toInt() ??
          (json['hourly_rate'] as num?)?.toInt(),
      sessionType: json['session_type'] as String?,
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
      'facility_id': facilityId,
      'session_type': sessionType,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
