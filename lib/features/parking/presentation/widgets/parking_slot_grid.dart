import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/parking_slot.dart';

class ParkingSlotGrid extends StatelessWidget {
  final List<ParkingSlot> slots;
  final String? selectedSlotId;
  final Function(ParkingSlot) onSlotTap;

  const ParkingSlotGrid({
    super.key,
    required this.slots,
    this.selectedSlotId,
    required this.onSlotTap,
  });

  @override
  Widget build(BuildContext context) {
    // Group slots into columns A, B, C
    final columnA = slots.where((s) => s.slotNumber.startsWith('A')).toList();
    final columnB = slots.where((s) => s.slotNumber.startsWith('B')).toList();
    final columnC = slots.where((s) => s.slotNumber.startsWith('C')).toList();

    // If no column grouping, split evenly
    List<ParkingSlot> leftSlots;
    List<ParkingSlot> centerSlots;
    List<ParkingSlot> rightSlots;

    if (columnA.isNotEmpty || columnB.isNotEmpty || columnC.isNotEmpty) {
      leftSlots = columnA;
      centerSlots = columnB;
      rightSlots = columnC;
    } else {
      // Split slots into 3 columns
      final thirdSize = (slots.length / 3).ceil();
      leftSlots = slots.take(thirdSize).toList();
      centerSlots = slots.skip(thirdSize).take(thirdSize).toList();
      rightSlots = slots.skip(thirdSize * 2).toList();
    }

    // Determine max rows
    final maxRows = [
      leftSlots.length,
      centerSlots.length,
      rightSlots.length,
    ].reduce((a, b) => a > b ? a : b);
    final rowCount = maxRows > 0 ? maxRows : 8;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Column headers
          Row(
            children: [
              const SizedBox(width: 28),
              Expanded(
                child: Center(
                  child: Text(
                    'A',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'B',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'C',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Slot grid
          ...List.generate(rowCount, (rowIndex) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  // Row number
                  SizedBox(
                    width: 28,
                    child: Text(
                      '${rowIndex + 1}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  // Column A
                  Expanded(
                    child: rowIndex < leftSlots.length
                        ? _buildSlotItem(leftSlots[rowIndex])
                        : _buildEmptySlot(),
                  ),
                  const SizedBox(width: 6),
                  // Column B
                  Expanded(
                    child: rowIndex < centerSlots.length
                        ? _buildSlotItem(centerSlots[rowIndex])
                        : _buildEmptySlot(),
                  ),
                  const SizedBox(width: 6),
                  // Column C
                  Expanded(
                    child: rowIndex < rightSlots.length
                        ? _buildSlotItem(rightSlots[rowIndex])
                        : _buildEmptySlot(),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptySlot() {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  Widget _buildSlotItem(ParkingSlot slot) {
    final isSelected = slot.id == selectedSlotId;

    Color backgroundColor;
    Color? iconColor;
    bool showCar = false;

    if (isSelected) {
      backgroundColor = AppColors.primary;
    } else if (slot.isAvailable) {
      backgroundColor = AppColors.primary;
    } else if (slot.isReserved) {
      backgroundColor = const Color(0xFFD9D9D9);
    } else {
      // Occupied
      backgroundColor = const Color(0xFFD9D9D9);
      showCar = true;
      iconColor = AppColors.textSecondary;
    }

    return GestureDetector(
      onTap: () => onSlotTap(slot),
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: showCar
              ? Icon(Icons.directions_car, color: iconColor, size: 18)
              : null,
        ),
      ),
    );
  }
}

/// Stats section showing availability with progress bar
class ParkingStats extends StatelessWidget {
  final int total;
  final int occupied;
  final int available;
  final int reserved;

  const ParkingStats({
    super.key,
    required this.total,
    required this.occupied,
    required this.available,
    required this.reserved,
  });

  @override
  Widget build(BuildContext context) {
    final progressValue = total > 0 ? occupied / total : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Occupied count with progress bar
        Row(
          children: [
            Text(
              '$occupied/$total occupied',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Progress bar
        Container(
          height: 8,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.textSecondary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progressValue,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Status indicators
        Row(
          children: [
            _buildStatItem(
              color: AppColors.primary, // Yellow for available (Figma)
              label: '$available Available',
            ),
            const SizedBox(width: 24),
            _buildStatItem(
              color: const Color(0xFFD9D9D9), // Gray for reservations
              label: '$reserved Reservations',
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Reservations will be available only for 30 minutes',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
