import '../../../parking/domain/entities/parking_session.dart';

/// Timestamps come from Supabase in UTC; show them in the phone's time zone.
DateTime _parseLocal(Object value) =>
    DateTime.parse(value.toString()).toLocal();

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
    super.paymentStatus,
    super.payment,
    required super.createdAt,
  });

  factory ParkingSessionModel.fromJson(Map<String, dynamic> json) {
    // Facility data may come from a join as nested object
    final facilityData = json['facilities'] as Map<String, dynamic>?;

    return ParkingSessionModel(
      id: (json['id'] as num).toInt(),
      plateNumber: json['plate_number'] as String,
      spotName: json['spot_name'] as String,
      entryTime: _parseLocal(json['entry_time']),
      exitTime: json['exit_time'] != null
          ? _parseLocal(json['exit_time'])
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
      paymentStatus: json['payment_status'] as String?,
      payment: _pickPayment(json['payments']),
      createdAt: _parseLocal(json['created_at']),
    );
  }

  /// A session normally has one payment; prefer a completed one if several.
  static SessionPayment? _pickPayment(Object? raw) {
    if (raw is! List || raw.isEmpty) return null;
    final payments = raw.cast<Map<String, dynamic>>();
    final chosen = payments.firstWhere(
      (p) => p['payment_status'] == 'completed',
      orElse: () => payments.last,
    );
    return SessionPayment(
      id: (chosen['id'] as num).toInt(),
      amount: (chosen['amount'] as num?)?.toInt() ?? 0,
      method: chosen['payment_method'] as String? ?? 'wallet',
      status: chosen['payment_status'] as String? ?? 'pending',
      transactionRef: chosen['transaction_ref'] as String?,
      createdAt: _parseLocal(chosen['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plate_number': plateNumber,
      'spot_name': spotName,
      'entry_time': entryTime.toUtc().toIso8601String(),
      'exit_time': exitTime?.toUtc().toIso8601String(),
      'duration_minutes': durationMinutes,
      'amount': amountLkr,
      'facility_id': facilityId,
      'session_type': sessionType,
      'payment_status': paymentStatus,
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }
}
