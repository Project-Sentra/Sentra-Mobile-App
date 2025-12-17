import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/text_fields.dart';
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
              const AppHeader(title: 'Parking Facilities'),
              const SizedBox(height: 16),
              // Search field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: BlocBuilder<ParkingBloc, ParkingState>(
                  builder: (context, state) {
                    return SearchTextField(
                      hintText: 'search parking facilities',
                      controller: _searchController,
                      onChanged: (query) {
                        context.read<ParkingBloc>().add(
                          SearchFacilities(query),
                        );
                      },
                    );
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
                                context.read<ParkingBloc>().add(
                                  const FetchParkingFacilities(),
                                );
                              },
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
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.textSecondary,
                                  letterSpacing: 1.2,
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
                          if (state.facilities.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                'ALL FACILITIES',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.textSecondary,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
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

  Widget _buildFacilityList(
    List<ParkingFacility> facilities,
    String emptyMessage,
  ) {
    if (facilities.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: AppTextStyles.bodyMedium.copyWith(
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
