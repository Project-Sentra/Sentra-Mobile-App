import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_header.dart';
import '../../domain/entities/parking_facility.dart';
import '../bloc/slot_bloc.dart';
import '../bloc/slot_event.dart';
import '../bloc/slot_state.dart';
import '../widgets/parking_slot_grid.dart';

class FacilityDetailPage extends StatefulWidget {
  final ParkingFacility facility;

  const FacilityDetailPage({super.key, required this.facility});

  @override
  State<FacilityDetailPage> createState() => _FacilityDetailPageState();
}

class _FacilityDetailPageState extends State<FacilityDetailPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SlotBloc>()..add(FetchParkingSlots(widget.facility.id)),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              ParkingHeader(
                title: widget.facility.name,
                price: widget.facility.pricePerHour?.toStringAsFixed(0),
                currency: widget.facility.currency,
                onBackPressed: () => context.pop(),
                onLocationPressed: () {},
                onFavoritePressed: () {},
              ),
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
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              state.errorMessage ?? '',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                context.read<SlotBloc>().add(
                                  FetchParkingSlots(widget.facility.id),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.textDark,
                              ),
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
                                  '/facilities/${widget.facility.id}/slot/${slot.id}',
                                  extra: {
                                    'slot': slot,
                                    'facility': widget.facility,
                                  },
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 24),
                          // Stats
                          ParkingStats(
                            total: state.slots.length,
                            occupied: state.slots
                                .where((s) => s.isOccupied)
                                .length,
                            available: state.slots
                                .where((s) => s.isAvailable)
                                .length,
                            reserved: state.slots
                                .where((s) => s.isReserved)
                                .length,
                          ),
                          const SizedBox(height: 100),
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
}
