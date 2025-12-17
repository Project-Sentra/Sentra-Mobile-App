import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/parking_facility.dart';
import '../../domain/entities/parking_slot.dart';
import '../bloc/slot_bloc.dart';
import '../bloc/slot_event.dart';
import '../bloc/slot_state.dart';
import '../widgets/parking_slot_grid.dart';

class FacilityDetailPage extends StatelessWidget {
  final ParkingFacility facility;

  const FacilityDetailPage({super.key, required this.facility});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SlotBloc>()..add(FetchParkingSlots(facility.id)),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context),
              // Content
              Expanded(
                child: BlocBuilder<SlotBloc, SlotState>(
                  builder: (context, state) {
                    if (state.status == SlotBlocStatus.loading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }

                    if (state.status == SlotBlocStatus.error) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Error loading slots',
                              style: AppTextStyles.bodyLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              state.errorMessage ?? '',
                              style: AppTextStyles.bodySmall,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                context.read<SlotBloc>().add(
                                  FetchParkingSlots(facility.id),
                                );
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Parking grid
                          ParkingSlotGrid(
                            slots: state.slots,
                            selectedSlotId: state.selectedSlot?.id,
                            onSlotTap: (slot) {
                              if (slot.isAvailable) {
                                context.push(
                                  '/facilities/${facility.id}/slot/${slot.id}',
                                  extra: {'slot': slot, 'facility': facility},
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 24),
                          // Stats
                          _buildStats(state.slots),
                          const SizedBox(height: 16),
                          // Info
                          Text(
                            'Reservations will be available only for 30 minutes',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
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

  Widget _buildStats(List<ParkingSlot> slots) {
    final total = slots.length;
    final occupied = slots.where((s) => s.isOccupied).length;
    final available = slots.where((s) => s.isAvailable).length;
    final reserved = slots.where((s) => s.isReserved).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            '$occupied/$total occupied',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatItem(
                color: AppColors.success,
                label: '$available Available',
              ),
              const SizedBox(width: 24),
              _buildStatItem(
                color: AppColors.warning,
                label: '$reserved Reservations',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }
}
