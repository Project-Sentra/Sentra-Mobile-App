import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class HomePage extends StatelessWidget {
  final Widget child;

  const HomePage({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context,
                  icon: Icons.sentiment_satisfied_alt,
                  path: '/facilities',
                  isSelected: _isSelected(context, '/facilities'),
                ),
                _buildNavItem(
                  context,
                  icon: Icons.square_outlined,
                  path: '/history',
                  isSelected: _isSelected(context, '/history'),
                ),
                _buildNavItem(
                  context,
                  icon: Icons.access_time,
                  path: '/reservations',
                  isSelected: _isSelected(context, '/reservations'),
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
        ),
      ),
    );
  }

  bool _isSelected(BuildContext context, String path) {
    final currentPath = GoRouterState.of(context).matchedLocation;
    return currentPath.startsWith(path);
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected ? AppColors.textDark : AppColors.textSecondary,
          size: 24,
        ),
      ),
    );
  }
}
