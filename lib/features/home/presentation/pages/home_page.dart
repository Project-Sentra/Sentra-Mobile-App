import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class HomePage extends StatelessWidget {
  final Widget child;

  const HomePage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: child,
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Parking - "P" icon (Figma design)
            _buildParkingNavItem(
              context,
              path: '/facilities',
              isSelected: _isSelected(context, '/facilities'),
            ),
            _buildNavItem(
              context,
              icon: Icons.confirmation_number_outlined,
              path: '/vehicles',
              isSelected: _isSelected(context, '/vehicles'),
            ),
            _buildNavItem(
              context,
              icon: Icons.history,
              path: '/history',
              isSelected: _isSelected(context, '/history'),
            ),
            _buildNavItem(
              context,
              icon: Icons.person_outline,
              path: '/profile',
              isSelected: _isSelected(context, '/profile'),
            ),
          ],
        ),
      ),
    );
  }

  bool _isSelected(BuildContext context, String path) {
    final currentPath = GoRouterState.of(context).matchedLocation;
    return currentPath.startsWith(path);
  }

  // Special "P" text icon for parking
  Widget _buildParkingNavItem(
    BuildContext context, {
    required String path,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => context.go(path),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          shape: BoxShape.circle,
          border: isSelected
              ? null
              : Border.all(color: AppColors.primary, width: 2),
        ),
        child: Center(
          child: Text(
            'P',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: isSelected ? AppColors.textDark : AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String path,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => context.go(path),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected ? AppColors.textDark : AppColors.primary,
          size: 26,
        ),
      ),
    );
  }
}
