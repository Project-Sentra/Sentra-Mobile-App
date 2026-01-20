import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../parking/domain/entities/reservation.dart';
import '../bloc/history_bloc.dart';
import '../bloc/history_event.dart';
import '../bloc/history_state.dart';
import '../widgets/active_session_card.dart';
import '../widgets/history_card.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    return BlocProvider(
      create: (_) {
        final bloc = sl<HistoryBloc>();
        if (userId != null) {
          bloc.add(FetchActiveSessions(userId));
          bloc.add(FetchParkingHistory(userId));
        }
        return bloc;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),
              const AppHeader(title: 'Parking History'),
              const SizedBox(height: 16),
              // Tab bar
              _buildTabBar(),
              const SizedBox(height: 16),
              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _ActiveTab(userId: userId),
                    _HistoryTab(userId: userId),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        dividerColor: Colors.transparent,
        labelColor: AppColors.textDark,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(text: 'Active'),
          Tab(text: 'History'),
        ],
      ),
    );
  }
}

class _ActiveTab extends StatelessWidget {
  final String? userId;

  const _ActiveTab({this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistoryBloc, HistoryState>(
      builder: (context, state) {
        if (state.isLoadingActive) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        final activeSessions = state.activeSessions;
        final activeReservations = state.activeReservations;

        if (activeSessions.isEmpty && activeReservations.isEmpty) {
          return _buildEmptyState();
        }

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            // Active sessions section
            if (activeSessions.isNotEmpty) ...[
              _buildSectionHeader('Active Parking'),
              const SizedBox(height: 12),
              ...activeSessions.map(
                (session) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ActiveSessionCard(session: session),
                ),
              ),
              const SizedBox(height: 16),
            ],
            // Active reservations section
            if (activeReservations.isNotEmpty) ...[
              _buildSectionHeader('Upcoming Reservations'),
              const SizedBox(height: 12),
              ...activeReservations.map(
                (reservation) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildReservationCard(reservation),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_parking,
            size: 80,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No active parking',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your active sessions will appear here',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildReservationCard(Reservation reservation) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'RESERVED',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                reservation.slotNumber,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            reservation.facilityName,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            'Slot: ${reservation.slotNumber}',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(
                '${_formatDateTime(reservation.startTime)} - ${_formatDateTime(reservation.endTime)}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class _HistoryTab extends StatelessWidget {
  final String? userId;

  const _HistoryTab({this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistoryBloc, HistoryState>(
      builder: (context, state) {
        if (state.isLoadingHistory) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (state.parkingHistory.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: state.parkingHistory.length,
          itemBuilder: (context, index) {
            final session = state.parkingHistory[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: HistoryCard(session: session),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No parking history',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your past sessions will appear here',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
