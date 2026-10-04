import 'package:equatable/equatable.dart';

/// The payment recorded for a finished parking session.
class SessionPayment extends Equatable {
  final int id;
  final int amount;
  final String method; // wallet | card | cash | bank_transfer
  final String status; // pending | completed | failed | refunded
  final String? transactionRef;
  final DateTime createdAt;

  const SessionPayment({
    required this.id,
    required this.amount,
    required this.method,
    required this.status,
    this.transactionRef,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    amount,
    method,
    status,
    transactionRef,
    createdAt,
  ];
}

class ParkingSession extends Equatable {
  final int id;
  final String plateNumber;
  final String spotName;
  final DateTime entryTime;
  final DateTime? exitTime;
  final int? durationMinutes;
  final int? amountLkr;
  final String? facilityName;
  final int? facilityId;
  final int? hourlyRate;
  final String? sessionType;
  final String? paymentStatus; // pending | paid | waived
  final SessionPayment? payment;
  final DateTime createdAt;

  const ParkingSession({
    required this.id,
    required this.plateNumber,
    required this.spotName,
    required this.entryTime,
    this.exitTime,
    this.durationMinutes,
    this.amountLkr,
    this.facilityName,
    this.facilityId,
    this.hourlyRate,
    this.sessionType,
    this.paymentStatus,
    this.payment,
    required this.createdAt,
  });

  bool get isActive => exitTime == null;
  bool get isCompleted => exitTime != null;

  /// Live duration since entry (for active sessions).
  Duration get liveDuration => isActive
      ? DateTime.now().difference(entryTime)
      : Duration(minutes: durationMinutes ?? 0);

  /// Estimated cost using facility hourly rate (falls back to LKR 100).
  int get estimatedCost {
    if (isCompleted) return amountLkr ?? 0;
    final rate = hourlyRate ?? 100;
    final hours = liveDuration.inMinutes / 60;
    return (hours.ceil() < 1 ? 1 : hours.ceil()) * rate;
  }

  String get formattedDuration {
    final d = isActive ? liveDuration : Duration(minutes: durationMinutes ?? 0);
    final hours = d.inHours;
    final mins = d.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${mins}m';
    }
    return '${mins}m';
  }

  String get formattedAmount {
    if (isActive) return 'LKR $estimatedCost';
    if (amountLkr == null) return '-';
    return 'LKR $amountLkr';
  }

  /// Receipt number shown to the driver, e.g. SEN-000123.
  String get receiptNumber => 'SEN-${id.toString().padLeft(6, '0')}';

  /// Hours billed: started hours, at least one (matches the backend).
  int get billedHours {
    final minutes = durationMinutes ?? 0;
    final hours = (minutes / 60).ceil();
    return hours < 1 ? 1 : hours;
  }

  bool get isPaid => paymentStatus == 'paid' || payment?.status == 'completed';
  bool get isWaived =>
      paymentStatus == 'waived' || sessionType == 'subscription';

  /// Human readable payment state for receipts.
  String get paymentLabel {
    if (isWaived) return 'Covered by subscription';
    if (isPaid) return 'Paid';
    return 'Payment pending';
  }

  @override
  List<Object?> get props => [
    id,
    plateNumber,
    spotName,
    entryTime,
    exitTime,
    durationMinutes,
    amountLkr,
    facilityName,
    facilityId,
    hourlyRate,
    sessionType,
    paymentStatus,
    payment,
    createdAt,
  ];
}
