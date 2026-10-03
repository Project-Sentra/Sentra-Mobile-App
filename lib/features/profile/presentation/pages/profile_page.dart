import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/user_profile.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
  }

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
            child: BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, state) {
                if (state.status == ProfileStatus.loading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (state.status == ProfileStatus.error) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          size: 48,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Error loading profile',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            if (userId != null) {
                              context.read<ProfileBloc>().add(
                                FetchUserProfile(userId),
                              );
                            }
                          },
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text('Try Again'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.textDark,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final profile = state.profile;

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      _buildHeader(context, profile),
                      const SizedBox(height: 20),
                      _buildProfileCard(profile),
                      const SizedBox(height: 16),
                      _buildQuickStats(context, profile),
                      const SizedBox(height: 28),
                      _buildSectionHeader('ACTIVITY & PARKING'),
                      const SizedBox(height: 10),
                      _buildMenuItem(
                        icon: Icons.history_rounded,
                        title: 'Parking & Booking History',
                        subtitle: 'View active passes & past receipts',
                        onTap: () => context.push('/history'),
                      ),
                      _buildMenuItem(
                        icon: Icons.credit_card_rounded,
                        title: 'Payment Methods',
                        subtitle: 'Manage saved cards & billing',
                        onTap: () => context.push('/profile/payment-methods'),
                      ),
                      const SizedBox(height: 24),
                      _buildSectionHeader('PREFERENCES & SUPPORT'),
                      const SizedBox(height: 10),
                      _buildMenuItem(
                        icon: Icons.notifications_none_rounded,
                        title: 'Notifications',
                        subtitle: 'Parking alerts & reminders',
                        onTap: () => context.push('/profile/notifications'),
                      ),
                      _buildMenuItem(
                        icon: Icons.headset_mic_outlined,
                        title: 'Help & Support',
                        subtitle: 'FAQs, contact & guides',
                        onTap: () => context.push('/profile/help-support'),
                      ),
                      const SizedBox(height: 24),
                      _buildSectionHeader('ACCOUNT'),
                      const SizedBox(height: 10),
                      _buildMenuItem(
                        icon: Icons.person_outline_rounded,
                        title: 'Edit Profile Information',
                        subtitle: 'Update name, contact & avatar',
                        onTap: () => _navigateToEditProfile(context, profile),
                      ),
                      _buildMenuItem(
                        icon: Icons.logout_rounded,
                        title: 'Sign Out',
                        subtitle: 'Log out of this device',
                        onTap: () => _showSignOutConfirmation(context),
                        isDestructive: true,
                      ),
                      const SizedBox(height: 28),
                      Center(
                        child: Text(
                          'Sentra v1.0.0 • Smart Parking Management',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.textSecondary.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserProfile? profile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Profile',
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Manage your vehicles & parking account',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => _navigateToEditProfile(context, profile),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.cardBorder, width: 1),
            ),
            child: const Icon(
              Icons.edit_outlined,
              size: 20,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard(UserProfile? profile) {
    final displayName = profile?.fullName != null && profile!.fullName!.trim().isNotEmpty
        ? profile.fullName!
        : (profile?.email.split('@').first ?? 'User');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF242628), Color(0xFF161718)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar with neon yellow accent ring
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ClipOval(
              child: profile?.avatarUrl != null && profile!.avatarUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: profile.avatarUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.surfaceLight,
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.surfaceLight,
                        child: const Icon(
                          Icons.person_rounded,
                          size: 42,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  : Container(
                      color: AppColors.surfaceLight,
                      child: const Icon(
                        Icons.person_rounded,
                        size: 42,
                        color: AppColors.textSecondary,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  displayName,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  profile?.email ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                // Verified member badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'VERIFIED DRIVER',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, UserProfile? profile) {
    final activeCount = profile?.activeReservations ?? 0;
    final totalCount = profile?.totalReservations ?? 0;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.directions_car_rounded,
            title: 'My Garage',
            subtitle: 'Vehicles',
            onTap: () => context.go('/vehicles'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.history_rounded,
            title: '$totalCount',
            subtitle: 'Bookings',
            onTap: () => context.push('/history'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.local_parking_rounded,
            title: activeCount > 0 ? '$activeCount Active' : 'None',
            subtitle: 'Live Passes',
            highlight: activeCount > 0,
            onTap: () => context.push('/history'),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool highlight = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: highlight
                ? AppColors.primary.withValues(alpha: 0.6)
                : AppColors.cardBorder,
            width: highlight ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: highlight ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: highlight ? AppColors.primary : AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDestructive
              ? AppColors.error.withValues(alpha: 0.25)
              : AppColors.cardBorder,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDestructive
                        ? AppColors.error.withValues(alpha: 0.12)
                        : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: isDestructive ? AppColors.error : AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDestructive
                              ? AppColors.error
                              : AppColors.textPrimary,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToEditProfile(
    BuildContext context,
    UserProfile? profile,
  ) async {
    final profileBloc = context.read<ProfileBloc>();
    final supabaseClient = Supabase.instance.client;
    final result = await context.push<bool>('/profile/edit', extra: profile);
    // Refresh profile if changes were saved
    if (result == true) {
      if (!context.mounted) return;
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId != null) {
        profileBloc.add(FetchUserProfile(userId));
      }
    }
  }

  void _showSignOutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF222426),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Sign Out',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to sign out of your Sentra account?',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<AuthBloc>().add(const AuthSignOutRequested());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            child: Text(
              'Sign Out',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
