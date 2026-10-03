import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/error_sanitizer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../booking/presentation/bloc/booking_bloc.dart';
import '../../../booking/presentation/bloc/booking_event.dart';
import '../../../booking/presentation/bloc/booking_state.dart';
import '../../../payment/domain/usecases/process_payment_usecase.dart';
import '../../../vehicles/domain/entities/vehicle.dart';
import '../../../vehicles/presentation/bloc/vehicle_bloc.dart';
import '../../../vehicles/presentation/bloc/vehicle_state.dart';
import '../../domain/entities/parking_location.dart';
import '../../domain/entities/parking_slot.dart';

class BookingBottomSheet extends StatefulWidget {
  final ParkingSlot spot;
  final ParkingLocation location;
  final VoidCallback onBookingSuccess;

  const BookingBottomSheet({
    super.key,
    required this.spot,
    required this.location,
    required this.onBookingSuccess,
  });

  @override
  State<BookingBottomSheet> createState() => _BookingBottomSheetState();
}

class _BookingBottomSheetState extends State<BookingBottomSheet> {
  int _durationHours = 2;
  Vehicle? _selectedVehicle;
  final _plateController = TextEditingController();
  bool _useManualPlate = false;
  final DateTime _startTime = DateTime.now();
  bool _isPaying = false;

  @override
  void dispose() {
    _plateController.dispose();
    super.dispose();
  }

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

  Future<void> _handlePaymentFlow(
    BuildContext context,
    BookingState state,
  ) async {
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
        if (context.mounted) {
          ErrorSanitizer.showError(context, failure.message);
        }

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
        // Mark reservation as paid/confirmed in DB
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
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookingBloc, BookingState>(
      listener: (context, state) async {
        if (state.bookingSuccess && !_isPaying) {
          FocusScope.of(context).unfocus();
          await _handlePaymentFlow(context, state);
        } else if (state.errorMessage != null) {
          ErrorSanitizer.showError(context, state.errorMessage!);
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
