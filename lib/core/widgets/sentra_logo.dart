import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// Sentra Logo widget that displays the official brand logo.
/// Defaults to crisp white (`AppColors.white`) for Sentra's dark theme.
class SentraLogo extends StatelessWidget {
  final double? size;
  final double? width;
  final double? height;
  final Color? color;
  final bool isDark;
  final bool showText;

  const SentraLogo({
    super.key,
    this.size,
    this.width,
    this.height,
    this.color,
    this.isDark = false,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    final logoColor = color ?? (isDark ? AppColors.textDark : AppColors.white);
    final effectiveHeight = height ?? (size != null && size! > 80 ? 48.0 : (size ?? 42.0));
    final effectiveWidth = width;

    return Image.asset(
      'assets/images/logoDark.png',
      width: effectiveWidth,
      height: effectiveHeight,
      fit: BoxFit.contain,
      color: logoColor,
      colorBlendMode: BlendMode.srcIn,
      errorBuilder: (context, error, stackTrace) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_parking_rounded,
              color: logoColor,
              size: effectiveHeight,
            ),
            const SizedBox(width: 8),
            Text(
              'Sentra',
              style: GoogleFonts.poppins(
                fontSize: effectiveHeight * 0.7,
                fontWeight: FontWeight.w700,
                color: logoColor,
                letterSpacing: -0.5,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Simple text-only Sentra logo
class SentraTextLogo extends StatelessWidget {
  final double fontSize;
  final Color? color;

  const SentraTextLogo({super.key, this.fontSize = 24, this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Sentra',
      style: GoogleFonts.poppins(
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: color ?? AppColors.white,
        letterSpacing: -0.5,
      ),
    );
  }
}
