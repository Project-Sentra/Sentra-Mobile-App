import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/vehicle.dart';

class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback? onDelete;
  final VoidCallback? onSetDefault;
  final VoidCallback? onTap;

  const VehicleCard({
    super.key,
    required this.vehicle,
    this.onDelete,
    this.onSetDefault,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(20),
          border: vehicle.isDefault
              ? Border.all(color: AppColors.primary, width: 2)
              : null,
        ),
        child: Row(
          children: [
            // Car icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.directions_car,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            // Vehicle info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          vehicle.licensePlate,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      if (vehicle.isDefault)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'DEFAULT',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (vehicle.vehicleName != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      vehicle.vehicleName!,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                  if (vehicle.vehicleMake != null ||
                      vehicle.vehicleModel != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      [
                        vehicle.vehicleMake,
                        vehicle.vehicleModel,
                      ].where((e) => e != null).join(' '),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Delete button
            if (onDelete != null)
              IconButton(
                onPressed: () => _showDeleteConfirmation(context),
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                  size: 22,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Vehicle',
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to remove this vehicle?',
          style: GoogleFonts.poppins(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete?.call();
            },
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
