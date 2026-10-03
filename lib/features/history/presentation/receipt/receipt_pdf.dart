import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../parking/domain/entities/parking_session.dart';

final _dateTime = DateFormat('d MMM yyyy, HH:mm');
final _money = NumberFormat.decimalPattern('en_US');

String formatLkr(int amount) => 'LKR ${_money.format(amount)}';

String paymentMethodLabel(String method) => switch (method) {
  'wallet' => 'Sentra wallet',
  'card' => 'Card',
  'cash' => 'Cash',
  'bank_transfer' => 'Bank transfer',
  _ => method,
};

/// Label/value rows shared by the on-screen receipt and the PDF.
List<MapEntry<String, String>> receiptDetails(ParkingSession s) => [
  MapEntry('Facility', s.facilityName ?? 'Sentra parking'),
  MapEntry('Vehicle', s.plateNumber),
  MapEntry('Spot', s.spotName),
  MapEntry('Entry', _dateTime.format(s.entryTime)),
  if (s.exitTime != null) MapEntry('Exit', _dateTime.format(s.exitTime!)),
  MapEntry('Duration', s.formattedDuration),
];

/// Charge rows: billed hours x rate, then the total.
List<MapEntry<String, String>> receiptCharges(ParkingSession s) => [
  if (s.isWaived)
    const MapEntry('Parking fee', 'Subscription')
  else if (s.hourlyRate != null)
    MapEntry(
      '${s.billedHours} h x ${formatLkr(s.hourlyRate!)}',
      formatLkr(s.amountLkr ?? s.billedHours * s.hourlyRate!),
    ),
];

List<MapEntry<String, String>> receiptPayment(ParkingSession s) => [
  MapEntry('Status', s.paymentLabel),
  if (s.payment != null) ...[
    MapEntry('Method', paymentMethodLabel(s.payment!.method)),
    MapEntry('Paid on', _dateTime.format(s.payment!.createdAt)),
    if (s.payment!.transactionRef != null)
      MapEntry('Reference', s.payment!.transactionRef!),
  ],
];

/// Build an A5 PDF receipt for a completed session.
Future<Uint8List> buildReceiptPdf(ParkingSession s) {
  const brand = PdfColor.fromInt(0xFFE2E600);
  const ink = PdfColor.fromInt(0xFF111111);
  const muted = PdfColor.fromInt(0xFF777777);
  final doc = pw.Document(
    title: 'Sentra receipt ${s.receiptNumber}',
    author: 'Sentra',
  );

  pw.Widget row(MapEntry<String, String> e, {bool bold = false}) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 3),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(e.key, style: const pw.TextStyle(color: muted, fontSize: 10)),
        pw.Text(
          e.value,
          style: pw.TextStyle(
            fontSize: bold ? 13 : 10,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      ],
    ),
  );

  pw.Widget section(String title, List<MapEntry<String, String>> rows) =>
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(height: 14),
          pw.Text(
            title.toUpperCase(),
            style: pw.TextStyle(
              fontSize: 8,
              color: muted,
              letterSpacing: 1.2,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Divider(color: PdfColors.grey300, height: 8),
          ...rows.map(row),
        ],
      );

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a5,
      margin: const pw.EdgeInsets.all(28),
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.all(14),
            decoration: const pw.BoxDecoration(
              color: ink,
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'SENTRA',
                  style: pw.TextStyle(
                    color: brand,
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'PARKING RECEIPT',
                      style: const pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 9,
                      ),
                    ),
                    pw.Text(
                      s.receiptNumber,
                      style: const pw.TextStyle(color: brand, fontSize: 9),
                    ),
                  ],
                ),
              ],
            ),
          ),
          section('Parking', receiptDetails(s)),
          section('Charges', receiptCharges(s)),
          pw.SizedBox(height: 6),
          row(
            MapEntry(
              'Total',
              s.isWaived ? formatLkr(0) : formatLkr(s.amountLkr ?? 0),
            ),
            bold: true,
          ),
          section('Payment', receiptPayment(s)),
          pw.Spacer(),
          pw.Center(
            child: pw.Text(
              'Thank you for parking with Sentra.',
              style: const pw.TextStyle(color: muted, fontSize: 9),
            ),
          ),
        ],
      ),
    ),
  );
  return doc.save();
}
