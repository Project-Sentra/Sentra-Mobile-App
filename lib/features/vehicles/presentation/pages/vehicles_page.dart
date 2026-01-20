import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_header.dart';
import '../../domain/entities/vehicle.dart';
import '../bloc/vehicle_bloc.dart';
import '../bloc/vehicle_event.dart';
import '../bloc/vehicle_state.dart';
import '../widgets/vehicle_card.dart';
import '../widgets/add_vehicle_dialog.dart';

class VehiclesPage extends StatefulWidget {
  const VehiclesPage({super.key});

  @override
  State<VehiclesPage> createState() => _VehiclesPageState();
}

class _VehiclesPageState extends State<VehiclesPage> {
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
    final userId = Supabase.instance.client.auth.currentUser?.id;

    return BlocProvider(
      create: (_) {
        final bloc = sl<VehicleBloc>();
        if (userId != null) {
          bloc.add(FetchVehicles(userId));
        }
        return bloc;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),
              const AppHeader(title: 'My Vehicles'),
              const SizedBox(height: 16),
              Expanded(
                child: BlocConsumer<VehicleBloc, VehicleState>(
                  listener: (context, state) {
                    if (state.status == VehicleStatus.added) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Vehicle added successfully!',
                            style: GoogleFonts.poppins(),
                          ),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    } else if (state.status == VehicleStatus.deleted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Vehicle removed',
                            style: GoogleFonts.poppins(),
                          ),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    } else if (state.status == VehicleStatus.error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            state.errorMessage ?? 'An error occurred',
                            style: GoogleFonts.poppins(),
                          ),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state.status == VehicleStatus.loading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }

                    if (state.vehicles.isEmpty) {
                      return _buildEmptyState(context, userId);
                    }

                    return _buildVehicleList(context, state.vehicles, userId);
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: BlocBuilder<VehicleBloc, VehicleState>(
          builder: (context, state) {
            return FloatingActionButton(
              onPressed: () => _showAddVehicleDialog(context, userId),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: AppColors.textDark),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String? userId) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_car_outlined,
            size: 80,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No vehicles added yet',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your vehicle to start parking',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddVehicleDialog(context, userId),
            icon: const Icon(Icons.add),
            label: Text(
              'Add Vehicle',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textDark,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleList(
    BuildContext context,
    List<Vehicle> vehicles,
    String? userId,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: vehicles.length,
      itemBuilder: (context, index) {
        final vehicle = vehicles[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: VehicleCard(
            vehicle: vehicle,
            onDelete: () {
              if (userId != null) {
                context.read<VehicleBloc>().add(
                  DeleteVehicle(vehicleId: vehicle.id, userId: userId),
                );
              }
            },
            onSetDefault: () {
              // TODO: Implement set default
            },
          ),
        );
      },
    );
  }

  void _showAddVehicleDialog(BuildContext context, String? userId) {
    if (userId == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<VehicleBloc>(),
        child: AddVehicleDialog(userId: userId),
      ),
    );
  }
}
