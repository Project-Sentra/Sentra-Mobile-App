import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/parking_slot.dart';

class SpotCard extends StatelessWidget {
  final ParkingSlot spot;
  final ValueChanged<ParkingSlot>? onTap;

  const SpotCard({
    super.key,
    required this.spot,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    String statusText;

    switch (spot.status) {
      case SlotStatus.available:
        color = Colors.green;
        icon = Icons.local_parking;
        statusText = 'Available';
        break;
      case SlotStatus.occupied:
        color = Colors.red;
        icon = Icons.directions_car;
        statusText = 'Occupied';
        break;
      case SlotStatus.reserved:
        color = Colors.orange;
        icon = Icons.bookmark;
        statusText = 'Reserved';
        break;
      case SlotStatus.disabled:
        color = Colors.grey;
        icon = Icons.block;
        statusText = 'Disabled';
        break;
    }

    final isInteractive = spot.isAvailable && onTap != null;

    return GestureDetector(
      onTap: isInteractive ? () => onTap!(spot) : null,
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(
              spot.slotName,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              statusText,
              style: GoogleFonts.poppins(fontSize: 10, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
