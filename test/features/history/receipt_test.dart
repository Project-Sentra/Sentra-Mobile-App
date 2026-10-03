import 'package:flutter_test/flutter_test.dart';
import 'package:sentra_mobile/features/history/data/models/parking_session_model.dart';
import 'package:sentra_mobile/features/history/presentation/receipt/receipt_pdf.dart';

Map<String, dynamic> _sessionJson({
  int amount = 450,
  String paymentStatus = 'paid',
  String sessionType = 'walk_in',
  List<Map<String, dynamic>>? payments,
}) => {
  'id': 123,
  'plate_number': 'WP CAB-1234',
  'spot_name': 'A-07',
  'entry_time': '2026-10-03T03:00:00+00:00',
  'exit_time': '2026-10-03T05:10:00+00:00',
  'duration_minutes': 130,
  'amount': amount,
  'facility_id': 1,
  'session_type': sessionType,
  'payment_status': paymentStatus,
  'created_at': '2026-10-03T03:00:00+00:00',
  'facilities': {'name': 'Sentra Main Parking', 'hourly_rate': 150},
  'payments':
      payments ??
      [
        {
          'id': 9,
          'amount': amount,
          'payment_method': 'wallet',
          'payment_status': 'completed',
          'transaction_ref': null,
          'created_at': '2026-10-03T05:10:01+00:00',
        },
      ],
};

void main() {
  group('ParkingSessionModel', () {
    test('converts UTC timestamps to local time', () {
      final s = ParkingSessionModel.fromJson(_sessionJson());
      expect(s.entryTime.isUtc, isFalse);
      expect(s.entryTime, DateTime.utc(2026, 10, 3, 3).toLocal());
    });

    test('reads the facility and the completed payment', () {
      final s = ParkingSessionModel.fromJson(
        _sessionJson(
          payments: [
            {
              'id': 1,
              'amount': 450,
              'payment_method': 'card',
              'payment_status': 'failed',
              'created_at': '2026-10-03T05:10:00Z',
            },
            {
              'id': 2,
              'amount': 450,
              'payment_method': 'wallet',
              'payment_status': 'completed',
              'created_at': '2026-10-03T05:11:00Z',
            },
          ],
        ),
      );
      expect(s.facilityName, 'Sentra Main Parking');
      expect(s.payment!.id, 2);
      expect(s.isPaid, isTrue);
    });

    test('works without payments', () {
      final json = _sessionJson(paymentStatus: 'pending')..remove('payments');
      final s = ParkingSessionModel.fromJson(json);
      expect(s.payment, isNull);
      expect(s.paymentLabel, 'Payment pending');
    });
  });

  group('receipt', () {
    test('number, billed hours and charge line', () {
      final s = ParkingSessionModel.fromJson(_sessionJson());
      expect(s.receiptNumber, 'SEN-000123');
      expect(s.billedHours, 3); // 2h10m -> 3 started hours
      expect(receiptCharges(s).single.key, '3 h x LKR 150');
      expect(receiptCharges(s).single.value, 'LKR 450');
      expect(
        receiptPayment(s).map((e) => e.key),
        containsAll(['Status', 'Method', 'Paid on']),
      );
    });

    test('subscription sessions are shown as covered', () {
      final s = ParkingSessionModel.fromJson(
        _sessionJson(
          amount: 0,
          paymentStatus: 'waived',
          sessionType: 'subscription',
          payments: [],
        ),
      );
      expect(s.paymentLabel, 'Covered by subscription');
      expect(receiptCharges(s).single.value, 'Subscription');
    });

    test('builds a PDF document', () async {
      final s = ParkingSessionModel.fromJson(_sessionJson());
      final bytes = await buildReceiptPdf(s);
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
      expect(bytes.length, greaterThan(1000));
    });
  });
}
