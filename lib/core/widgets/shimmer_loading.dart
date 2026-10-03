import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Core animated gradient shimmer effect for dark mode skeleton loading.
class Shimmer extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;
  final Duration duration;

  const Shimmer({
    super.key,
    required this.child,
    this.baseColor = const Color(0xFF1E2022),
    this.highlightColor = const Color(0xFF2D3035),
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
              transform: _SlidingGradientTransform(slidePercent: _controller.value),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({required this.slidePercent});

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * (slidePercent * 2 - 1), 0.0, 0.0);
  }
}

/// Generic rounded shimmer block placeholder.
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  const ShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 8,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: const Color(0xFF222428),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Skeleton placeholder for parking facilities list.
class FacilityListSkeleton extends StatelessWidget {
  final int count;

  const FacilityListSkeleton({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: count,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const ShimmerBox(
                      width: 52,
                      height: 52,
                      borderRadius: 12,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          ShimmerBox(width: 160, height: 16, borderRadius: 6),
                          SizedBox(height: 8),
                          ShimmerBox(width: 110, height: 12, borderRadius: 4),
                        ],
                      ),
                    ),
                    const ShimmerBox(width: 48, height: 26, borderRadius: 14),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: AppColors.cardBorder, height: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    ShimmerBox(width: 90, height: 14, borderRadius: 4),
                    ShimmerBox(width: 70, height: 14, borderRadius: 4),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Skeleton placeholder for parking spots grid & floor selector.
class SpotGridSkeleton extends StatelessWidget {
  const SpotGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Column(
        children: [
          // Stat chips row placeholder
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: const [
                Expanded(child: ShimmerBox(height: 38, borderRadius: 12)),
                SizedBox(width: 12),
                Expanded(child: ShimmerBox(height: 38, borderRadius: 12)),
                SizedBox(width: 12),
                Expanded(child: ShimmerBox(height: 38, borderRadius: 12)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Floor tab selector placeholder
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: const [
                ShimmerBox(width: 80, height: 36, borderRadius: 18),
                SizedBox(width: 10),
                ShimmerBox(width: 80, height: 36, borderRadius: 18),
                SizedBox(width: 10),
                ShimmerBox(width: 80, height: 36, borderRadius: 18),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Spots grid placeholder
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: 9,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder, width: 1),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      ShimmerBox(width: 32, height: 16, borderRadius: 4),
                      SizedBox(height: 12),
                      ShimmerBox(width: 44, height: 26, borderRadius: 8),
                      SizedBox(height: 12),
                      ShimmerBox(width: 50, height: 10, borderRadius: 4),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton placeholder for vehicles page.
class VehicleListSkeleton extends StatelessWidget {
  final int count;

  const VehicleListSkeleton({super.key, this.count = 3});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: count,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.cardBorder, width: 1),
            ),
            child: Row(
              children: [
                const ShimmerBox(
                  width: 56,
                  height: 56,
                  borderRadius: 16,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      ShimmerBox(width: 130, height: 18, borderRadius: 6),
                      SizedBox(height: 8),
                      ShimmerBox(width: 90, height: 13, borderRadius: 4),
                    ],
                  ),
                ),
                const ShimmerBox(width: 36, height: 36, borderRadius: 18),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Skeleton placeholder for parking history and bookings.
class HistoryListSkeleton extends StatelessWidget {
  final int count;

  const HistoryListSkeleton({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: count,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const ShimmerBox(
                      width: 44,
                      height: 44,
                      borderRadius: 12,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          ShimmerBox(width: 120, height: 16, borderRadius: 6),
                          SizedBox(height: 6),
                          ShimmerBox(width: 80, height: 12, borderRadius: 4),
                        ],
                      ),
                    ),
                    const ShimmerBox(width: 72, height: 24, borderRadius: 12),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(color: AppColors.cardBorder, height: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    ShimmerBox(width: 110, height: 12, borderRadius: 4),
                    ShimmerBox(width: 60, height: 14, borderRadius: 4),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
