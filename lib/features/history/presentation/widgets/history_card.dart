import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../parking/domain/entities/parking_session.dart';

class HistoryCard extends StatelessWidget {
  final ParkingSession session;
  final VoidCallback? onTap;

  const HistoryCard({super.key, required this.session, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.local_parking,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.facilityName,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _formatDate(session.entryTime),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status badge
                _buildStatusBadge(session.status),
              ],
            ),
            const SizedBox(height: 16),
            // Details row
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // License plate
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vehicle',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          session.licensePlate,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Duration
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Duration',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDuration(session.duration),
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Amount
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Total',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          session.totalAmount != null
                              ? 'RM ${session.totalAmount!.toStringAsFixed(2)}'
                              : '-',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Time details
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${_formatTime(session.entryTime)} - ${session.exitTime != null ? _formatTime(session.exitTime!) : 'N/A'}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ParkingSessionStatus status) {
    Color bgColor;
    Color textColor;
    String statusText;

    switch (status) {
      case ParkingSessionStatus.completed:
        bgColor = AppColors.success.withValues(alpha: 0.15);
        textColor = AppColors.success;
        statusText = 'COMPLETED';
        break;
      case ParkingSessionStatus.active:
        bgColor = AppColors.primary.withValues(alpha: 0.15);
        textColor = AppColors.primary;
        statusText = 'ACTIVE';
        break;
      case ParkingSessionStatus.cancelled:
        bgColor = AppColors.error.withValues(alpha: 0.15);
        textColor = AppColors.error;
        statusText = 'CANCELLED';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        statusText,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(double? hours) {
    if (hours == null) return '-';
    final totalMinutes = (hours * 60).round();
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    if (h > 0) {
      return '${h}h ${m}m';
    }
    return '${m}m';
  }
}
