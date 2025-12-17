import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) {
            final bloc = sl<ProfileBloc>();
            if (userId != null) {
              bloc.add(FetchUserProfile(userId));
              bloc.add(FetchUserReservations(userId));
            }
            return bloc;
          },
        ),
        BlocProvider(create: (_) => sl<AuthBloc>()),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.unauthenticated) {
            context.go('/sign-in');
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                const AppHeader(title: 'Profile'),
                Expanded(
                  child: BlocBuilder<ProfileBloc, ProfileState>(
                    builder: (context, state) {
                      if (state.status == ProfileStatus.loading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        );
                      }

                      if (state.status == ProfileStatus.error) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Error loading profile',
                                style: AppTextStyles.bodyLarge,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  if (userId != null) {
                                    context.read<ProfileBloc>().add(
                                      FetchUserProfile(userId),
                                    );
                                  }
                                },
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }

                      final profile = state.profile;

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Profile card with circular progress
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  // Circular progress avatar
                                  SizedBox(
                                    width: 80,
                                    height: 80,
                                    child: Stack(
                                      children: [
                                        CustomPaint(
                                          size: const Size(80, 80),
                                          painter: CircularProgressPainter(
                                            progress:
                                                profile?.completionPercentage ??
                                                0.5,
                                            progressColor: AppColors.primary,
                                            backgroundColor: AppColors
                                                .textSecondary
                                                .withValues(alpha: 0.3),
                                            strokeWidth: 4,
                                          ),
                                        ),
                                        Center(
                                          child: CircleAvatar(
                                            radius: 32,
                                            backgroundColor:
                                                AppColors.backgroundLight,
                                            backgroundImage:
                                                profile?.avatarUrl != null
                                                ? NetworkImage(
                                                    profile!.avatarUrl!,
                                                  )
                                                : null,
                                            child: profile?.avatarUrl == null
                                                ? Icon(
                                                    Icons.person,
                                                    size: 32,
                                                    color:
                                                        AppColors.textSecondary,
                                                  )
                                                : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Profile info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          profile?.fullName ?? 'User',
                                          style: AppTextStyles.titleLarge
                                              .copyWith(
                                                color: AppColors.textPrimary,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          profile?.email ?? '',
                                          style: AppTextStyles.bodySmall
                                              .copyWith(
                                                color: AppColors.textSecondary,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Stats
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    'Total\nReservations',
                                    '${profile?.totalReservations ?? 0}',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildStatCard(
                                    'Active\nReservations',
                                    '${profile?.activeReservations ?? 0}',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Menu items
                            _buildMenuItem(
                              icon: Icons.person_outline,
                              title: 'Edit Profile',
                              onTap: () {},
                            ),
                            _buildMenuItem(
                              icon: Icons.history,
                              title: 'Reservation History',
                              onTap: () {},
                            ),
                            _buildMenuItem(
                              icon: Icons.payment,
                              title: 'Payment Methods',
                              onTap: () {},
                            ),
                            _buildMenuItem(
                              icon: Icons.notifications_outlined,
                              title: 'Notifications',
                              onTap: () {},
                            ),
                            _buildMenuItem(
                              icon: Icons.help_outline,
                              title: 'Help & Support',
                              onTap: () {},
                            ),
                            _buildMenuItem(
                              icon: Icons.logout,
                              title: 'Sign Out',
                              onTap: () {
                                context.read<AuthBloc>().add(
                                  const AuthSignOutRequested(),
                                );
                              },
                              isDestructive: true,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.headlineLarge.copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? AppColors.error : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDestructive
                      ? AppColors.error
                      : AppColors.textPrimary,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 24),
          ],
        ),
      ),
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color backgroundColor;
  final double strokeWidth;

  CircularProgressPainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
