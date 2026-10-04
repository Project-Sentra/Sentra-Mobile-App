import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printing/printing.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../parking/domain/entities/parking_session.dart';
import '../receipt/receipt_pdf.dart';

/// Receipt for a completed parking session (FR-07), shareable as a PDF.
class ReceiptPage extends StatefulWidget {
  final ParkingSession session;

  const ReceiptPage({super.key, required this.session});

  @override
  State<ReceiptPage> createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  bool _sharing = false;

  ParkingSession get session => widget.session;

  Future<void> _sharePdf() async {
    setState(() => _sharing = true);
    try {
      final bytes = await buildReceiptPdf(session);
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'sentra-receipt-${session.receiptNumber}.pdf',
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not create the PDF receipt')),
        );
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = session.isPaid || session.isWaived
        ? AppColors.success
        : AppColors.warning;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Receipt',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  _header(statusColor),
                  _divider(),
                  _section('Parking', receiptDetails(session)),
                  _section('Charges', receiptCharges(session)),
                  _total(),
                  _divider(),
                  _section('Payment', receiptPayment(session)),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _sharing ? null : _sharePdf,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: _sharing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.textDark,
                        ),
                      )
                    : const Icon(Icons.ios_share),
                label: Text(
                  'Share PDF receipt',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(Color statusColor) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              session.isPaid || session.isWaived
                  ? Icons.check_rounded
                  : Icons.schedule_rounded,
              color: statusColor,
              size: 30,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            session.isWaived ? formatLkr(0) : formatLkr(session.amountLkr ?? 0),
            style: GoogleFonts.poppins(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            session.paymentLabel,
            style: GoogleFonts.poppins(fontSize: 13, color: statusColor),
          ),
          const SizedBox(height: 6),
          Text(
            session.receiptNumber,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textSecondary,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      children: List.generate(
        30,
        (i) => Expanded(
          child: Container(
            height: 1,
            color: i.isEven ? AppColors.cardBorder : Colors.transparent,
          ),
        ),
      ),
    ),
  );

  Widget _section(String title, List<MapEntry<String, String>> rows) {
    if (rows.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: 11,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          ...rows.map((e) => _row(e.key, e.value)),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: bold ? 15 : 13,
              color: bold ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.poppins(
                fontSize: bold ? 15 : 13,
                color: bold ? AppColors.primary : AppColors.textPrimary,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _total() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
    child: _row(
      'Total',
      session.isWaived ? formatLkr(0) : formatLkr(session.amountLkr ?? 0),
      bold: true,
    ),
  );
}
