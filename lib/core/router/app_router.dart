import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/sign_in_page.dart';
import '../../features/auth/presentation/pages/sign_up_page.dart';
import '../../features/parking/presentation/pages/parking_facilities_page.dart';
import '../../features/parking/presentation/pages/facility_detail_page.dart';
import '../../features/parking/presentation/pages/slot_detail_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/parking/domain/entities/parking_facility.dart';
import '../../features/parking/domain/entities/parking_slot.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      final isAuthenticated = Supabase.instance.client.auth.currentUser != null;
      final isOnAuthPage =
          state.matchedLocation == '/sign-in' ||
          state.matchedLocation == '/sign-up' ||
          state.matchedLocation == '/splash';

      if (!isAuthenticated && !isOnAuthPage) {
        return '/sign-in';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),
      GoRoute(
        path: '/sign-in',
        builder: (context, state) => const SignInPage(),
      ),
      GoRoute(
        path: '/sign-up',
        builder: (context, state) => const SignUpPage(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => HomePage(child: child),
        routes: [
          GoRoute(
            path: '/facilities',
            builder: (context, state) => const ParkingFacilitiesPage(),
            routes: [
              GoRoute(
                path: ':facilityId',
                builder: (context, state) {
                  final facility = state.extra as ParkingFacility;
                  return FacilityDetailPage(facility: facility);
                },
                routes: [
                  GoRoute(
                    path: 'slot/:slotId',
                    builder: (context, state) {
                      final extra = state.extra as Map<String, dynamic>;
                      return SlotDetailPage(
                        slot: extra['slot'] as ParkingSlot,
                        facility: extra['facility'] as ParkingFacility,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/history',
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('History'))),
          ),
          GoRoute(
            path: '/reservations',
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('Reservations'))),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),
    ],
  );
}
