import '../../../parking/domain/entities/parking_receipt.dart';

class ParkingReceiptModel extends ParkingReceipt {
  const ParkingReceiptModel({
    required super.id,
    required super.parkingSessionId,
    required super.facilityName,
    required super.facilityAddress,
    required super.licensePlate,
    super.slotNumber,
    required super.entryTime,
    required super.exitTime,
    required super.duration,
    required super.ratePerHour,
    required super.subtotal,
    super.tax,
    required super.totalAmount,
    super.currency,
    required super.paymentMethod,
    super.transactionId,
    required super.createdAt,
  });

  factory ParkingReceiptModel.fromJson(Map<String, dynamic> json) {
    return ParkingReceiptModel(
      id: json['id'] as String,
      parkingSessionId: json['parking_session_id'] as String,
      facilityName: json['facility_name'] as String,
      facilityAddress: json['facility_address'] as String? ?? '',
      licensePlate: json['license_plate'] as String,
      slotNumber: json['slot_number'] as String?,
      entryTime: DateTime.parse(json['entry_time'] as String),
      exitTime: DateTime.parse(json['exit_time'] as String),
      duration: (json['duration'] as num).toDouble(),
      ratePerHour: (json['rate_per_hour'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
      tax: json['tax'] != null ? (json['tax'] as num).toDouble() : null,
      totalAmount: (json['total_amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'LKR',
      paymentMethod: json['payment_method'] as String,
      transactionId: json['transaction_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parking_session_id': parkingSessionId,
      'facility_name': facilityName,
      'facility_address': facilityAddress,
      'license_plate': licensePlate,
      'slot_number': slotNumber,
      'entry_time': entryTime.toIso8601String(),
      'exit_time': exitTime.toIso8601String(),
      'duration': duration,
      'rate_per_hour': ratePerHour,
      'subtotal': subtotal,
      'tax': tax,
      'total_amount': totalAmount,
      'currency': currency,
      'payment_method': paymentMethod,
      'transaction_id': transactionId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
