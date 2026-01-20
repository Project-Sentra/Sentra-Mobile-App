import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_header.dart';
import '../../domain/entities/parking_facility.dart';
import '../../domain/entities/parking_slot.dart';
import '../bloc/slot_bloc.dart';
import '../bloc/slot_event.dart';
import '../bloc/slot_state.dart';

class SlotDetailPage extends StatefulWidget {
  final ParkingSlot slot;
  final ParkingFacility facility;

  const SlotDetailPage({super.key, required this.slot, required this.facility});

  @override
  State<SlotDetailPage> createState() => _SlotDetailPageState();
}

class _SlotDetailPageState extends State<SlotDetailPage> {
  @override
  void initState() {
    super.initState();
    // Light background needs dark status bar icons
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SlotBloc>(),
      child: BlocConsumer<SlotBloc, SlotState>(
        listener: (context, state) {
          if (state.status == SlotBlocStatus.reserved) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Slot reserved successfully!',
                  style: GoogleFonts.poppins(),
                ),
                backgroundColor: AppColors.success,
              ),
            );
            context.go('/facilities');
          } else if (state.status == SlotBlocStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.errorMessage ?? 'Failed to reserve slot',
                  style: GoogleFonts.poppins(),
                ),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.white,
            body: SafeArea(
              child: Column(
                children: [
                  // Light background header
                  SlotDetailHeader(
                    title: widget.facility.name,
                    price: widget.facility.pricePerHour?.toStringAsFixed(0),
                    currency: widget.facility.currency,
                    onBackPressed: () => context.pop(),
                    onLocationPressed: () {},
                    onFavoritePressed: () {},
                  ),
                  // Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const Spacer(),
                          // Slot label
                          Text(
                            'SLOT',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Slot card
                          _buildSlotCard(),
                          const SizedBox(height: 48),
                          // Reserve button
                          _buildReserveButton(context, state),
                          const SizedBox(height: 16),
                          // Info text
                          Text(
                            'Reservations will be available only for 30 minutes',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const Spacer(),
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

  Widget _buildSlotCard() {
    return Container(
      width: 200,
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.slot.slotNumber,
            style: GoogleFonts.poppins(
              fontSize: 56,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          // Blue underline
          Container(
            width: 60,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF4A90D9),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReserveButton(BuildContext context, SlotState state) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: state.status == SlotBlocStatus.reserving
            ? null
            : () {
                final userId = Supabase.instance.client.auth.currentUser?.id;
                if (userId != null) {
                  context.read<SlotBloc>().add(
                    ReserveSlot(
                      slotId: widget.slot.id,
                      facilityId: widget.facility.id,
                      userId: userId,
                      durationMinutes: 30,
                    ),
                  );
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.textDark,
          foregroundColor: AppColors.primary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: state.status == SlotBlocStatus.reserving
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            : Text(
                'Reserve',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
      ),
    );
  }
}
