import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_header.dart';
import '../../domain/entities/parking_location.dart';
import '../../domain/entities/parking_slot.dart';
import '../bloc/parking_bloc.dart';
import '../bloc/parking_event.dart';
import '../bloc/parking_state.dart';

class ParkingFacilitiesPage extends StatefulWidget {
  const ParkingFacilitiesPage({super.key});

  @override
  State<ParkingFacilitiesPage> createState() => _ParkingFacilitiesPageState();
}

class _ParkingFacilitiesPageState extends State<ParkingFacilitiesPage> {
  final _searchController = TextEditingController();

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
    _searchController.dispose();
    super.dispose();
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
        // Slots grid
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
              : _buildSpotGrid(state.spots),
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

  Widget _buildSpotGrid(List<ParkingSlot> spots) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: spots.length,
      itemBuilder: (context, index) {
        final spot = spots[index];
        return _buildSpotCard(spot);
      },
    );
  }

  Widget _buildSpotCard(ParkingSlot spot) {
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
              // TODO: Show booking dialog
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: Text(
          'Book Slot ${spot.slotName}',
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Would you like to pre-book this parking slot?',
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
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement booking
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Booking feature coming soon!',
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textDark,
            ),
            child: const Text('Book Now'),
          ),
        ],
      ),
    );
  }
}
