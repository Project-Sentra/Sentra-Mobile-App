import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/buttons.dart';
import '../../domain/entities/parking_facility.dart';
import '../../domain/entities/parking_slot.dart';
import '../bloc/slot_bloc.dart';
import '../bloc/slot_event.dart';
import '../bloc/slot_state.dart';

class SlotDetailPage extends StatelessWidget {
  final ParkingSlot slot;
  final ParkingFacility facility;

  const SlotDetailPage({super.key, required this.slot, required this.facility});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SlotBloc>(),
      child: BlocConsumer<SlotBloc, SlotState>(
        listener: (context, state) {
          if (state.status == SlotBlocStatus.reserved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Slot reserved successfully!'),
                backgroundColor: AppColors.success,
              ),
            );
            context.go('/facilities');
          } else if (state.status == SlotBlocStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Failed to reserve slot'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Column(
                children: [
                  // Header
                  _buildHeader(context),
                  // Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Slot display
                          Expanded(
                            child: Center(
                              child: Container(
                                width: 200,
                                height: 160,
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppColors.primary,
                                    width: 3,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'SLOT',
                                      style: AppTextStyles.labelMedium.copyWith(
                                        color: AppColors.textSecondary,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      slot.slotNumber,
                                      style: AppTextStyles.displayLarge
                                          .copyWith(
                                            color: AppColors.textDark,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Reserve button
                          PrimaryButton(
                            text: 'Reserve',
                            isLoading: state.status == SlotBlocStatus.reserving,
                            onPressed: () {
                              final userId =
                                  Supabase.instance.client.auth.currentUser?.id;
                              if (userId != null) {
                                context.read<SlotBloc>().add(
                                  ReserveSlot(
                                    slotId: slot.id,
                                    facilityId: facility.id,
                                    userId: userId,
                                    durationMinutes: 30,
                                  ),
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Reservations will be available only for 30 minutes',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: const Icon(
                  Icons.arrow_back,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  facility.name,
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${facility.currency} ${facility.pricePerHour?.toStringAsFixed(0) ?? '0'}/hr',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.location_on,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.favorite_border,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
