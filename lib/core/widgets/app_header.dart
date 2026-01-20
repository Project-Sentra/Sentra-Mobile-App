import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;

  const AppHeader({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (showBackButton) ...[
            GestureDetector(
              onTap: () => context.pop(),
              child: const Icon(Icons.arrow_back, color: AppColors.textDark),
            ),
            const SizedBox(width: 12),
          ],
          // Stylized header badge (clean yellow, no border)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
          const Spacer(),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}

/// Parking page header with dark card containing title (for facility detail page)
class ParkingHeader extends StatelessWidget {
  final String title;
  final String? price;
  final String? currency;
  final VoidCallback? onBackPressed;
  final VoidCallback? onLocationPressed;
  final VoidCallback? onFavoritePressed;
  final bool isFavorite;

  const ParkingHeader({
    super.key,
    required this.title,
    this.price,
    this.currency,
    this.onBackPressed,
    this.onLocationPressed,
    this.onFavoritePressed,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          if (onBackPressed != null)
            GestureDetector(
              onTap: onBackPressed,
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(
                  Icons.chevron_left,
                  color: AppColors.textPrimary,
                  size: 28,
                ),
              ),
            ),
          // Dark card with yellow title
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
                height: 1.2,
              ),
            ),
          ),
          if (price != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                // Price tag
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${currency ?? 'LKR'} $price/hr',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Location icon in circle
                GestureDetector(
                  onTap: onLocationPressed,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.textPrimary,
                        width: 1.5,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on_outlined,
                      color: AppColors.textPrimary,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Favorite icon
                GestureDetector(
                  onTap: onFavoritePressed,
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? AppColors.error : AppColors.textPrimary,
                    size: 24,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Slot detail page header (light background, simple text)
class SlotDetailHeader extends StatelessWidget {
  final String title;
  final String? price;
  final String? currency;
  final VoidCallback? onBackPressed;
  final VoidCallback? onLocationPressed;
  final VoidCallback? onFavoritePressed;
  final bool isFavorite;

  const SlotDetailHeader({
    super.key,
    required this.title,
    this.price,
    this.currency,
    this.onBackPressed,
    this.onLocationPressed,
    this.onFavoritePressed,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          if (onBackPressed != null)
            GestureDetector(
              onTap: onBackPressed,
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(
                  Icons.chevron_left,
                  color: AppColors.textDark,
                  size: 28,
                ),
              ),
            ),
          // Title text (black, not in card)
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
              height: 1.2,
            ),
          ),
          if (price != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                // Price tag
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${currency ?? 'LKR'} $price/hr',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Location icon in circle
                GestureDetector(
                  onTap: onLocationPressed,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.textDark, width: 1.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on_outlined,
                      color: AppColors.textDark,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Favorite icon
                GestureDetector(
                  onTap: onFavoritePressed,
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? AppColors.error : AppColors.textDark,
                    size: 24,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
