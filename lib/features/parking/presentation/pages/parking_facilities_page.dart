import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_header.dart';
import '../../domain/entities/parking_location.dart';
import '../../domain/entities/parking_slot.dart';
import '../bloc/parking_bloc.dart';
import '../bloc/parking_event.dart';
import '../bloc/parking_state.dart';
import '../../../booking/presentation/bloc/booking_bloc.dart';
import '../../../booking/presentation/bloc/booking_event.dart';
import '../../../booking/presentation/bloc/booking_state.dart';
import '../../../payment/domain/usecases/process_payment_usecase.dart';
import '../../../vehicles/domain/entities/vehicle.dart';
import '../../../vehicles/presentation/bloc/vehicle_bloc.dart';
import '../../../vehicles/presentation/bloc/vehicle_event.dart';
import '../../../vehicles/presentation/bloc/vehicle_state.dart';

class ParkingFacilitiesPage extends StatefulWidget {
  const ParkingFacilitiesPage({super.key});

  @override
  State<ParkingFacilitiesPage> createState() => _ParkingFacilitiesPageState();
}

class _ParkingFacilitiesPageState extends State<ParkingFacilitiesPage> {
  final _searchController = TextEditingController();
  Timer? _slotRefreshTimer;

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
  void dispose() {
    _slotRefreshTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _startSlotRefresh(ParkingBloc bloc, int locationId) {
    _slotRefreshTimer?.cancel();
    _slotRefreshTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => bloc.add(FetchSpotsByLocation(locationId)),
    );
  }

  void _stopSlotRefresh() {
    _slotRefreshTimer?.cancel();
    _slotRefreshTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = sl<ParkingBloc>();
        bloc.add(const FetchParkingLocations());
        return bloc;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: BlocBuilder<ParkingBloc, ParkingState>(
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _buildHeader(context, state),
                  const SizedBox(height: 16),
                  Expanded(child: _buildContent(context, state)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ParkingState state) {
    if (state.isViewingSpots) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.primary),
              onPressed: () {
                _stopSlotRefresh();
                context.read<ParkingBloc>().add(const BackToLocations());
              },
            ),
            Expanded(
              child: Text(
                state.selectedLocation?.name ?? 'Parking Slots',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return const AppHeader(title: 'Parking Locations');
  }

  Widget _buildContent(BuildContext context, ParkingState state) {
    if (state.status == ParkingStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state.status == ParkingStatus.error) {
      return _buildErrorView(context, state);
    }

    // Show slots view if a location is selected
    if (state.isViewingSpots) {
      return _buildSlotsView(context, state);
    }

    // Show locations view
    return _buildLocationsView(context, state);
  }

  Widget _buildErrorView(BuildContext context, ParkingState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            'Error loading data',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              state.errorMessage ?? '',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<ParkingBloc>().add(const FetchParkingLocations());
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

  // ========== LOCATIONS VIEW ==========
  Widget _buildLocationsView(BuildContext context, ParkingState state) {
    if (state.locations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, color: AppColors.textSecondary, size: 64),
            const SizedBox(height: 16),
            Text(
              'No parking locations available',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: state.locations.length,
      itemBuilder: (context, index) {
        final location = state.locations[index];
        return _buildLocationCard(context, location);
      },
    );
  }

  Widget _buildLocationCard(BuildContext context, ParkingLocation location) {
    final availabilityColor = location.availableSlots > 0
        ? Colors.green
        : Colors.red;

    return GestureDetector(
      onTap: () {
        context.read<ParkingBloc>().add(SelectLocation(location));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardDark, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.local_parking,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location.name,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (location.address != null)
                        Text(
                          location.address!,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildLocationStat(
                  'Available',
                  '${location.availableSlots}',
                  Colors.green,
                ),
                const SizedBox(width: 12),
                _buildLocationStat(
                  'Occupied',
                  '${location.occupiedSlots}',
                  Colors.red,
                ),
                const SizedBox(width: 12),
                _buildLocationStat(
                  'Total',
                  '${location.totalSlots}',
                  AppColors.primary,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: availabilityColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    location.formattedPrice,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: availabilityColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ========== SLOTS VIEW ==========
  Widget _buildSlotsView(BuildContext context, ParkingState state) {
    // Activate auto-refresh when viewing spots
    if (state.selectedLocation != null && _slotRefreshTimer == null) {
      _startSlotRefresh(
        context.read<ParkingBloc>(),
        state.selectedLocation!.id,
      );
    }

    if (state.status == ParkingStatus.loadingSpots) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    return Column(
      children: [
        // Stats row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildStatChip('Available', state.availableCount, Colors.green),
              const SizedBox(width: 12),
              _buildStatChip('Occupied', state.occupiedCount, Colors.red),
              if (state.reservedCount > 0) ...[
                const SizedBox(width: 12),
                _buildStatChip('Reserved', state.reservedCount, Colors.orange),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Slots grid with pull-to-refresh
        Expanded(
          child: state.spots.isEmpty
              ? Center(
                  child: Text(
                    'No slots available at this location',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                )
              : RefreshIndicator(
                  color: AppColors.primary,
                  backgroundColor: AppColors.cardDark,
                  onRefresh: () async {
                    if (state.selectedLocation != null) {
                      context.read<ParkingBloc>().add(
                        FetchSpotsByLocation(state.selectedLocation!.id),
                      );
                      // Wait a moment for the state to update
                      await Future.delayed(const Duration(milliseconds: 500));
                    }
                  },
                  child: _buildSpotGrid(context, state.spots),
                ),
        ),
      ],
    );
  }

  Widget _buildStatChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            '$label: $count',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpotGrid(BuildContext context, List<ParkingSlot> spots) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: spots.length,
      itemBuilder: (ctx, index) {
        final spot = spots[index];
        return _buildSpotCard(context, spot);
      },
    );
  }

  Widget _buildSpotCard(BuildContext context, ParkingSlot spot) {
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

    return GestureDetector(
      onTap: spot.isAvailable
          ? () {
              _showBookingDialog(context, spot);
            }
          : null,
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

  void _showBookingDialog(BuildContext context, ParkingSlot spot) {
    final parkingState = context.read<ParkingBloc>().state;
    final location = parkingState.selectedLocation;

    if (location == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: No location selected',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) {
              final bloc = sl<VehicleBloc>();
              final userId = Supabase.instance.client.auth.currentUser?.id;
              if (userId != null) {
                bloc.add(FetchVehicles(userId));
              }
              return bloc;
            },
          ),
          BlocProvider(create: (_) => sl<BookingBloc>()),
        ],
        child: _BookingBottomSheet(
          spot: spot,
          location: location,
          onBookingSuccess: () {
            // Refresh spots after booking
            context.read<ParkingBloc>().add(SelectLocation(location));
          },
        ),
      ),
    );
  }
}

class _BookingBottomSheet extends StatefulWidget {
  final ParkingSlot spot;
  final ParkingLocation location;
  final VoidCallback onBookingSuccess;

  const _BookingBottomSheet({
    required this.spot,
    required this.location,
    required this.onBookingSuccess,
  });

  @override
  State<_BookingBottomSheet> createState() => _BookingBottomSheetState();
}

class _BookingBottomSheetState extends State<_BookingBottomSheet> {
  Vehicle? _selectedVehicle;
  final _plateController = TextEditingController();
  final DateTime _startTime = DateTime.now();
  int _durationHours = 1;
  bool _useManualPlate = false;
  bool _isPaying = false;

  Widget _buildButtonLoading(String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _plateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookingBloc, BookingState>(
      listener: (context, state) async {
        if (state.bookingSuccess && !_isPaying) {
          FocusScope.of(context).unfocus();

          final reservation = state.lastCreatedReservation;
          final userId = Supabase.instance.client.auth.currentUser?.id;
          if (reservation == null || userId == null) {
            context.read<BookingBloc>().add(ResetBookingSuccess());
            return;
          }

          final bookingBloc = context.read<BookingBloc>();
          final messenger = ScaffoldMessenger.of(context);
          final navigator = Navigator.of(context);
          final supabaseClient = Supabase.instance.client;
          final slotName = widget.spot.slotName;
          final onBookingSuccess = widget.onBookingSuccess;

          setState(() {
            _isPaying = true;
          });

          final bookingFee = widget.location.pricePerHour * _durationHours;

          final paymentResult = await sl<ProcessPaymentUseCase>()(
            ProcessPaymentParams(
              userId: userId,
              paymentMethodId: 'stripe',
              amount: bookingFee,
              reservationId: reservation.id,
            ),
          );

          if (!mounted) return;

          await paymentResult.fold(
            (failure) async {
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    failure.message,
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: Colors.red,
                ),
              );

              // Payment failed/cancelled -> cancel reservation to release spot
              bookingBloc.add(
                    CancelReservation(
                      reservationId: reservation.id,
                      userId: userId,
                    ),
                  );

              bookingBloc.add(ResetBookingSuccess());
            },
            (_) async {
              // Mark reservation as paid/confirmed (best-effort)
              try {
                await supabaseClient
                    .from('reservations')
                    .update({'payment_status': 'completed', 'status': 'confirmed'})
                    .eq('id', reservation.id);
              } catch (_) {}

              bookingBloc.add(ResetBookingSuccess());

              navigator.pop();
              onBookingSuccess();
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    'Payment successful. Booking confirmed for $slotName!',
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
          );

          if (context.mounted) {
            setState(() {
              _isPaying = false;
            });
          }
        } else if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!, style: GoogleFonts.poppins()),
              backgroundColor: Colors.red,
            ),
          );
          context.read<BookingBloc>().add(ClearBookingError());
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  'Book Parking Slot',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),

                // Spot & Location info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.local_parking,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.spot.slotName,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              widget.location.name,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            widget.location.formattedPrice,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            'per hour',
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
                const SizedBox(height: 24),

                // Vehicle selection
                Text(
                  'Select Vehicle',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                BlocBuilder<VehicleBloc, VehicleState>(
                  builder: (context, vehicleState) {
                    if (vehicleState.status == VehicleStatus.loading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }

                    final vehicles = vehicleState.vehicles;

                    if (vehicles.isEmpty && !_useManualPlate) {
                      return Column(
                        children: [
                          Text(
                            'No vehicles found. Enter plate number manually.',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildManualPlateInput(),
                        ],
                      );
                    }

                    return Column(
                      children: [
                        // Vehicle list
                        if (!_useManualPlate)
                          ...vehicles.map(
                            (vehicle) => _buildVehicleOption(vehicle),
                          ),

                        // Manual input toggle
                        if (!_useManualPlate && vehicles.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _useManualPlate = true;
                                _selectedVehicle = null;
                              });
                            },
                            child: Text(
                              'Enter plate number manually',
                              style: GoogleFonts.poppins(
                                color: AppColors.primary,
                              ),
                            ),
                          ),

                        // Manual plate input
                        if (_useManualPlate) ...[
                          _buildManualPlateInput(),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _useManualPlate = false;
                                _plateController.clear();
                              });
                            },
                            child: Text(
                              'Select from my vehicles',
                              style: GoogleFonts.poppins(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Duration selection
                Text(
                  'Duration',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    _buildDurationChip(1),
                    const SizedBox(width: 8),
                    _buildDurationChip(2),
                    const SizedBox(width: 8),
                    _buildDurationChip(4),
                    const SizedBox(width: 8),
                    _buildDurationChip(8),
                  ],
                ),
                const SizedBox(height: 24),

                // Total cost
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '${widget.location.currency} ${(widget.location.pricePerHour * _durationHours).toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Book button
                BlocBuilder<BookingBloc, BookingState>(
                  builder: (context, bookingState) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: !bookingState.isLoading && !_isPaying
                            ? () => _createBooking(context)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          disabledBackgroundColor: AppColors.textSecondary
                              .withValues(alpha: 0.3),
                        ),
                        child: bookingState.isLoading
                            ? _buildButtonLoading('Creating reservation...')
                            : _isPaying
                                ? _buildButtonLoading('Opening payment...')
                                : Text(
                                    'Confirm Booking',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),

                // Cancel button
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleOption(Vehicle vehicle) {
    final isSelected = _selectedVehicle?.id == vehicle.id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedVehicle = vehicle;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.15)
              : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.directions_car,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle.vehicleName ?? vehicle.licensePlate,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    vehicle.licensePlate,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (vehicle.isDefault)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Default',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: AppColors.primary,
                  ),
                ),
              ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildManualPlateInput() {
    return TextField(
      controller: _plateController,
      textCapitalization: TextCapitalization.characters,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: 'Enter plate number (e.g., ABC-1234)',
        hintStyle: GoogleFonts.poppins(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        prefixIcon: const Icon(
          Icons.directions_car,
          color: AppColors.textSecondary,
        ),
      ),
      style: GoogleFonts.poppins(color: AppColors.textPrimary),
    );
  }

  Widget _buildDurationChip(int hours) {
    final isSelected = _durationHours == hours;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _durationHours = hours;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.background,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '${hours}h',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _createBooking(BuildContext context) {
    FocusScope.of(context).unfocus();
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please login to book a parking slot',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final plateNumber =
        _selectedVehicle?.licensePlate ?? _plateController.text.trim();
    if (plateNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select a vehicle or enter a plate number',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final endTime = _startTime.add(Duration(hours: _durationHours));
    final bookingFee = widget.location.pricePerHour * _durationHours;

    context.read<BookingBloc>().add(
      CreateReservation(
        userId: userId,
        vehicleId: _selectedVehicle?.id,
        location: widget.location,
        spot: widget.spot,
        plateNumber: plateNumber,
        startTime: _startTime,
        endTime: endTime,
        bookingFee: bookingFee,
      ),
    );
  }
}
