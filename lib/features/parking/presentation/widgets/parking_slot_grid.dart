import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
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
    // Group slots by rows (assuming slot numbers like A1, A2, B1, B2, etc.)
    // For demo, we'll create a simple grid layout
    final leftSlots = <ParkingSlot>[];
    final rightSlots = <ParkingSlot>[];

    for (int i = 0; i < slots.length; i++) {
      if (i % 2 == 0) {
        leftSlots.add(slots[i]);
      } else {
        rightSlots.add(slots[i]);
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Entry arrow
          const Icon(
            Icons.arrow_downward,
            color: AppColors.textSecondary,
            size: 24,
          ),
          const SizedBox(height: 16),
          // Parking slots grid
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column
              Expanded(
                child: Column(
                  children: leftSlots.take(6).map((slot) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildSlotItem(slot),
                    );
                  }).toList(),
                ),
              ),
              // Center divider (road)
              Container(
                width: 60,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    for (int i = 0; i < 6; i++)
                      Container(
                        height: 52,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Center(
                          child: Container(
                            width: 2,
                            height: 20,
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Right column
              Expanded(
                child: Column(
                  children: rightSlots.take(6).map((slot) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildSlotItem(slot),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Exit arrow
          const Icon(
            Icons.arrow_downward,
            color: AppColors.textSecondary,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildSlotItem(ParkingSlot slot) {
    final isSelected = slot.id == selectedSlotId;

    Color backgroundColor;
    Color borderColor;

    if (isSelected) {
      backgroundColor = AppColors.primary;
      borderColor = AppColors.primary;
    } else if (slot.isAvailable) {
      backgroundColor = AppColors.slotAvailable;
      borderColor = AppColors.textSecondary.withValues(alpha: 0.3);
    } else if (slot.isReserved) {
      backgroundColor = AppColors.slotReserved;
      borderColor = AppColors.warning;
    } else {
      backgroundColor = AppColors.slotOccupied;
      borderColor = AppColors.textSecondary.withValues(alpha: 0.3);
    }

    return GestureDetector(
      onTap: () => onSlotTap(slot),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
        ),
        child: Center(
          child: slot.isOccupied
              ? Icon(
                  Icons.directions_car,
                  color: AppColors.textSecondary,
                  size: 20,
                )
              : Text(
                  slot.slotNumber,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isSelected
                        ? AppColors.textDark
                        : AppColors.textSecondary,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
        ),
      ),
    );
  }
}
