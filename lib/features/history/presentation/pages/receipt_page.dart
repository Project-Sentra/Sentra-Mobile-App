import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printing/printing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/error_sanitizer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../parking/domain/entities/parking_session.dart';
import '../../../payment/domain/usecases/process_payment_usecase.dart';
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
  bool _isPaying = false;
  late ParkingSession _currentSession;

  @override
  void initState() {
    super.initState();
    _currentSession = widget.session;
  }

  ParkingSession get session => _currentSession;

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

  Future<void> _handlePayNow() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      ErrorSanitizer.showError(
        context,
        'You must be signed in to make a payment.',
      );
      return;
    }

    final amountToPay = (_currentSession.amountLkr ?? 0).toDouble();
    if (amountToPay <= 0) {
      ErrorSanitizer.showError(context, 'Invalid payment amount.');
      return;
    }

    setState(() => _isPaying = true);

    try {
      final paymentResult = await sl<ProcessPaymentUseCase>()(
        ProcessPaymentParams(
          userId: userId,
          paymentMethodId: 'stripe',
          amount: amountToPay,
          parkingSessionId: _currentSession.id.toString(),
        ),
      );

      if (!mounted) return;

      await paymentResult.fold(
        (failure) async {
          if (mounted) {
            ErrorSanitizer.showError(context, failure.message);
          }
        },
        (payment) async {
          // Update status in Supabase table
          try {
            await Supabase.instance.client
                .from('parking_sessions')
                .update({'payment_status': 'paid'})
                .eq('id', _currentSession.id);
          } catch (_) {}

          if (mounted) {
            setState(() {
              _currentSession = ParkingSession(
                id: _currentSession.id,
                plateNumber: _currentSession.plateNumber,
                spotName: _currentSession.spotName,
                entryTime: _currentSession.entryTime,
                exitTime: _currentSession.exitTime,
                durationMinutes: _currentSession.durationMinutes,
                amountLkr: _currentSession.amountLkr,
                facilityName: _currentSession.facilityName,
                facilityId: _currentSession.facilityId,
                hourlyRate: _currentSession.hourlyRate,
                sessionType: _currentSession.sessionType,
                paymentStatus: 'paid',
                payment: SessionPayment(
                  id: int.tryParse(payment.id) ?? 0,
                  amount: payment.amount.round(),
                  method: 'card',
                  status: 'completed',
                  transactionRef: payment.transactionId,
                  createdAt: payment.createdAt,
                ),
                createdAt: _currentSession.createdAt,
              );
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Payment successful! LKR ${amountToPay.toStringAsFixed(0)} paid via Card.',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
      );
    } finally {
      if (mounted) {
        setState(() => _isPaying = false);
      }
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
            if (!session.isPaid && !session.isWaived) ...[
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isPaying ? null : _handlePayNow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textDark,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: _isPaying
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.textDark,
                          ),
                        )
                      : const Icon(Icons.credit_card_rounded),
                  label: Text(
                    _isPaying
                        ? 'Processing Payment...'
                        : 'Pay Now (${formatLkr(session.amountLkr ?? 0)})',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _sharing || _isPaying ? null : _sharePdf,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.cardBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: _sharing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.textPrimary,
                          ),
                        )
                      : const Icon(Icons.ios_share, size: 18),
                  label: Text(
                    'Share PDF receipt',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ] else ...[
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _sharing ? null : _sharePdf,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textDark,
                    elevation: 0,
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
