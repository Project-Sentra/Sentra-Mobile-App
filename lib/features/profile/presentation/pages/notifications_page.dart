import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _parkingAlerts = true;
  bool _reservationReminders = true;
  bool _paymentNotifications = true;
  bool _promotions = false;
  bool _sessionUpdates = true;
  bool _isLoading = true;

  static const _keyParkingAlerts = 'notif_parking_alerts';
  static const _keyReservationReminders = 'notif_reservation_reminders';
  static const _keyPaymentNotifications = 'notif_payment_notifications';
  static const _keyPromotions = 'notif_promotions';
  static const _keySessionUpdates = 'notif_session_updates';

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
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _parkingAlerts = prefs.getBool(_keyParkingAlerts) ?? true;
      _reservationReminders = prefs.getBool(_keyReservationReminders) ?? true;
      _paymentNotifications = prefs.getBool(_keyPaymentNotifications) ?? true;
      _promotions = prefs.getBool(_keyPromotions) ?? false;
      _sessionUpdates = prefs.getBool(_keySessionUpdates) ?? true;
      _isLoading = false;
    });
  }

  Future<void> _savePreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            _buildHeader(context),
            const SizedBox(height: 24),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader('Parking'),
                          const SizedBox(height: 12),
                          _buildToggleItem(
                            icon: Icons.local_parking,
                            title: 'Parking Alerts',
                            subtitle: 'Get notified about parking availability',
                            value: _parkingAlerts,
                            onChanged: (val) {
                              setState(() => _parkingAlerts = val);
                              _savePreference(_keyParkingAlerts, val);
                            },
                          ),
                          _buildToggleItem(
                            icon: Icons.timer_outlined,
                            title: 'Session Updates',
                            subtitle:
                                'Alerts when your parking session is ending',
                            value: _sessionUpdates,
                            onChanged: (val) {
                              setState(() => _sessionUpdates = val);
                              _savePreference(_keySessionUpdates, val);
                            },
                          ),
                          const SizedBox(height: 24),
                          _buildSectionHeader('Reservations'),
                          const SizedBox(height: 12),
                          _buildToggleItem(
                            icon: Icons.calendar_today,
                            title: 'Reservation Reminders',
                            subtitle:
                                'Reminders before your reservation starts',
                            value: _reservationReminders,
                            onChanged: (val) {
                              setState(() => _reservationReminders = val);
                              _savePreference(_keyReservationReminders, val);
                            },
                          ),
                          const SizedBox(height: 24),
                          _buildSectionHeader('Payments'),
                          const SizedBox(height: 12),
                          _buildToggleItem(
                            icon: Icons.payment_outlined,
                            title: 'Payment Notifications',
                            subtitle: 'Receipts and payment confirmations',
                            value: _paymentNotifications,
                            onChanged: (val) {
                              setState(() => _paymentNotifications = val);
                              _savePreference(_keyPaymentNotifications, val);
                            },
                          ),
                          const SizedBox(height: 24),
                          _buildSectionHeader('General'),
                          const SizedBox(height: 12),
                          _buildToggleItem(
                            icon: Icons.campaign_outlined,
                            title: 'Promotions & Offers',
                            subtitle: 'Discounts and special parking offers',
                            value: _promotions,
                            onChanged: (val) {
                              setState(() => _promotions = val);
                              _savePreference(_keyPromotions, val);
                            },
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              'Notifications',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
            inactiveThumbColor: AppColors.textSecondary,
            inactiveTrackColor: AppColors.surfaceLight,
          ),
        ],
      ),
    );
  }
}
