import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// Sentra Logo widget that displays the brand logo
/// Can be used with dark or light variants
class SentraLogo extends StatelessWidget {
  final double size;
  final bool isDark;
  final bool showText;

  const SentraLogo({
    super.key,
    this.size = 48,
    this.isDark = true,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDark ? AppColors.textDark : AppColors.primary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo icon - Globe with parking symbol
        SizedBox(
          width: size,
          height: size,
          child: Image.asset(
            'assets/images/logoDark.png',
            width: size,
            height: size,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to custom painted logo if image not found
              return CustomPaint(
                size: Size(size, size),
                painter: _SentraLogoPainter(color: color),
              );
            },
          ),
        ),
        if (showText) ...[
          SizedBox(width: size * 0.25),
          Text(
            'Sentra',
            style: GoogleFonts.poppins(
              fontSize: size * 0.75,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: -1,
            ),
          ),
        ],
      ],
    );
  }
}

/// Custom painter for the Sentra logo (fallback)
class _SentraLogoPainter extends CustomPainter {
  final Color color;

  _SentraLogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.06;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.42;

    // Draw outer circle
    canvas.drawCircle(center, radius, paint);

    // Draw horizontal lines (latitude)
    for (int i = -1; i <= 1; i++) {
      final y = center.dy + (radius * 0.5 * i);
      final dx = radius * (1 - (i.abs() * 0.3));
      canvas.drawLine(
        Offset(center.dx - dx, y),
        Offset(center.dx + dx, y),
        paint,
      );
    }

    // Draw vertical arc (longitude)
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, -1.57, 3.14, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
        color: color ?? AppColors.textSecondary,
        letterSpacing: -0.5,
      ),
    );
  }
}
