import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_header.dart';
import '../../domain/entities/parking_slot.dart';
import '../bloc/parking_bloc.dart';
import '../bloc/parking_event.dart';
import '../bloc/parking_state.dart';
import '../../../booking/presentation/bloc/booking_bloc.dart';
import '../../../vehicles/presentation/bloc/vehicle_bloc.dart';
import '../../../vehicles/presentation/bloc/vehicle_event.dart';
import '../widgets/facility_card.dart';
import '../widgets/stat_chip.dart';
import '../widgets/spot_card.dart';
import '../widgets/booking_bottom_sheet.dart';

class ParkingFacilitiesPage extends StatefulWidget {
  const ParkingFacilitiesPage({super.key});

  @override
  State<ParkingFacilitiesPage> createState() => _ParkingFacilitiesPageState();
}

class _ParkingFacilitiesPageState extends State<ParkingFacilitiesPage> {
  final _searchController = TextEditingController();
  RealtimeChannel? _realtimeChannel;
  int? _subscribedLocationId;

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
    _unsubscribeFromRealtime();
    _searchController.dispose();
    super.dispose();
  }

  void _subscribeToRealtime(ParkingBloc bloc, int locationId) {
    if (_subscribedLocationId == locationId && _realtimeChannel != null) {
      return;
    }
    _unsubscribeFromRealtime();
    _subscribedLocationId = locationId;

    final supabase = Supabase.instance.client;
    _realtimeChannel = supabase.channel('realtime:facility:$locationId')
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'parking_spots',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'facility_id',
          value: locationId,
        ),
        callback: (_) {
          bloc.add(RefreshSpotsSilently(locationId));
        },
      )
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'reservations',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'facility_id',
          value: locationId,
        ),
        callback: (_) {
          bloc.add(RefreshSpotsSilently(locationId));
        },
      )
      ..subscribe();
  }

  void _unsubscribeFromRealtime() {
    if (_realtimeChannel != null) {
      Supabase.instance.client.removeChannel(_realtimeChannel!);
      _realtimeChannel = null;
      _subscribedLocationId = null;
    }
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
                _unsubscribeFromRealtime();
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

    if (state.isViewingSpots) {
      return _buildSlotsView(context, state);
    }

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

  Widget _buildLocationsView(BuildContext context, ParkingState state) {
    if (state.locations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_off, color: AppColors.textSecondary, size: 64),
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
        return FacilityCard(
          location: location,
          onTap: () {
            context.read<ParkingBloc>().add(SelectLocation(location));
          },
        );
      },
    );
  }

  Widget _buildSlotsView(BuildContext context, ParkingState state) {
    // Activate Realtime subscription when viewing spots
    if (state.selectedLocation != null &&
        _subscribedLocationId != state.selectedLocation!.id) {
      _subscribeToRealtime(
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
              StatChip(
                label: 'Available',
                count: state.availableCount,
                color: Colors.green,
              ),
              const SizedBox(width: 12),
              StatChip(
                label: 'Occupied',
                count: state.occupiedCount,
                color: Colors.red,
              ),
              if (state.reservedCount > 0) ...[
                const SizedBox(width: 12),
                StatChip(
                  label: 'Reserved',
                  count: state.reservedCount,
                  color: Colors.orange,
                ),
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
                      await Future.delayed(const Duration(milliseconds: 500));
                    }
                  },
                  child: _buildSpotGrid(context, state.spots),
                ),
        ),
      ],
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
        return SpotCard(
          spot: spot,
          onTap: (selectedSpot) {
            _showBookingDialog(context, selectedSpot);
          },
        );
      },
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
        child: BookingBottomSheet(
          spot: spot,
          location: location,
          onBookingSuccess: () {
            context.read<ParkingBloc>().add(SelectLocation(location));
          },
        ),
      ),
    );
  }
}
