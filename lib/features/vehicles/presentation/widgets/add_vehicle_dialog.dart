import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/vehicle_bloc.dart';
import '../bloc/vehicle_event.dart';

class AddVehicleDialog extends StatefulWidget {
  final String userId;

  const AddVehicleDialog({super.key, required this.userId});

  @override
  State<AddVehicleDialog> createState() => _AddVehicleDialogState();
}

class _AddVehicleDialogState extends State<AddVehicleDialog> {
  final _formKey = GlobalKey<FormState>();
  final _licensePlateController = TextEditingController();
  final _vehicleNameController = TextEditingController();
  final _vehicleMakeController = TextEditingController();
  final _vehicleModelController = TextEditingController();
  bool _isDefault = false;

  @override
  void dispose() {
    _licensePlateController.dispose();
    _vehicleNameController.dispose();
    _vehicleMakeController.dispose();
    _vehicleModelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
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
                const SizedBox(height: 20),
                // Title
                Text(
                  'Add New Vehicle',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                // License plate field
                _buildTextField(
                  controller: _licensePlateController,
                  label: 'License Plate *',
                  hint: 'e.g. ABC-1234',
                  inputFormatters: [
                    UpperCaseTextFormatter(),
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9-]')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter license plate';
                    }
                    if (value.length < 4) {
                      return 'License plate too short';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Vehicle name field
                _buildTextField(
                  controller: _vehicleNameController,
                  label: 'Vehicle Name (optional)',
                  hint: 'e.g. My Car',
                ),
                const SizedBox(height: 16),
                // Make & Model row
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _vehicleMakeController,
                        label: 'Make',
                        hint: 'e.g. Toyota',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        controller: _vehicleModelController,
                        label: 'Model',
                        hint: 'e.g. Camry',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Set as default
                Row(
                  children: [
                    Checkbox(
                      value: _isDefault,
                      onChanged: (value) {
                        setState(() {
                          _isDefault = value ?? false;
                        });
                      },
                      activeColor: AppColors.primary,
                      checkColor: AppColors.textDark,
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isDefault = !_isDefault;
                        });
                      },
                      child: Text(
                        'Set as default vehicle',
                        style: GoogleFonts.poppins(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: Text(
                      'Add Vehicle',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          inputFormatters: inputFormatters,
          validator: validator,
          style: GoogleFonts.poppins(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<VehicleBloc>().add(
        AddVehicle(
          userId: widget.userId,
          licensePlate: _licensePlateController.text.trim(),
          vehicleName: _vehicleNameController.text.trim().isNotEmpty
              ? _vehicleNameController.text.trim()
              : null,
          vehicleMake: _vehicleMakeController.text.trim().isNotEmpty
              ? _vehicleMakeController.text.trim()
              : null,
          vehicleModel: _vehicleModelController.text.trim().isNotEmpty
              ? _vehicleModelController.text.trim()
              : null,
          isDefault: _isDefault,
        ),
      );
      Navigator.pop(context);
    }
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
