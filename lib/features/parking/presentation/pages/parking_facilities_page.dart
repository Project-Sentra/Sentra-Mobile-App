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
import '../bloc/parking_bloc.dart';
import '../bloc/parking_event.dart';
import '../bloc/parking_state.dart';
import '../widgets/facility_card.dart';

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
        bloc.add(const FetchParkingFacilities());
        final userId = Supabase.instance.client.auth.currentUser?.id;
        if (userId != null) {
          bloc.add(FetchRecentFacilities(userId));
        }
        return bloc;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const AppHeader(title: 'Parking Facilities'),
              const SizedBox(height: 16),
              // Search field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: BlocBuilder<ParkingBloc, ParkingState>(
                  builder: (context, state) {
                    return _buildSearchField(context);
                  },
                ),
              ),
              const SizedBox(height: 24),
              // Content
              Expanded(
                child: BlocBuilder<ParkingBloc, ParkingState>(
                  builder: (context, state) {
                    if (state.status == ParkingStatus.loading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }

                    if (state.status == ParkingStatus.error) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Error loading facilities',
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
                                context.read<ParkingBloc>().add(
                                  const FetchParkingFacilities(),
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

                    // Show search results if searching
                    if (_searchController.text.isNotEmpty) {
                      return _buildFacilityList(
                        state.searchResults,
                        'No facilities found',
                      );
                    }

                    // Show recent facilities and all facilities
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (state.recentFacilities.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                'RECENTS',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...state.recentFacilities.map(
                              (facility) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                child: FacilityCard(
                                  facility: facility,
                                  onTap: () =>
                                      _navigateToFacility(context, facility),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                          if (state.facilities.isNotEmpty &&
                              state.recentFacilities.isEmpty) ...[
                            ...state.facilities.map(
                              (facility) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                child: FacilityCard(
                                  facility: facility,
                                  onTap: () =>
                                      _navigateToFacility(context, facility),
                                ),
                              ),
                            ),
                          ],
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

  Widget _buildSearchField(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(24),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (query) {
          context.read<ParkingBloc>().add(SearchFacilities(query));
        },
        style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textDark),
        decoration: InputDecoration(
          hintText: 'search parking facilities',
          hintStyle: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.textHint,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.textHint,
            size: 22,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildFacilityList(
    List<ParkingFacility> facilities,
    String emptyMessage,
  ) {
    if (facilities.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: facilities.length,
      itemBuilder: (context, index) {
        final facility = facilities[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: FacilityCard(
            facility: facility,
            onTap: () => _navigateToFacility(context, facility),
          ),
        );
      },
    );
  }

  void _navigateToFacility(BuildContext context, ParkingFacility facility) {
    context.push('/facilities/${facility.id}', extra: facility);
  }
}
