import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/sign_in_page.dart';
import '../../features/auth/presentation/pages/sign_up_page.dart';
import '../../features/parking/presentation/pages/parking_facilities_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/payment_methods_page.dart';
import '../../features/profile/presentation/pages/notifications_page.dart';
import '../../features/profile/presentation/pages/help_support_page.dart';
import '../../features/profile/domain/entities/user_profile.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/vehicles/presentation/pages/vehicles_page.dart';
import '../../features/history/presentation/pages/history_page.dart';
import '../../features/booking/presentation/pages/my_bookings_page.dart';

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
          ),
          GoRoute(
            path: '/vehicles',
            builder: (context, state) => const VehiclesPage(),
          ),
          GoRoute(
            path: '/history',
            builder: (context, state) => const HistoryPage(),
          ),
          GoRoute(
            path: '/bookings',
            builder: (context, state) => const MyBookingsPage(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),
      // Routes outside ShellRoute (full-screen pages)
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) =>
            EditProfilePage(profile: state.extra as UserProfile?),
      ),
      GoRoute(
        path: '/profile/payment-methods',
        builder: (context, state) => const PaymentMethodsPage(),
      ),
      GoRoute(
        path: '/profile/notifications',
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: '/profile/help-support',
        builder: (context, state) => const HelpSupportPage(),
      ),
      GoRoute(
        path: '/profile/reservations',
        builder: (context, state) => const MyBookingsPage(showBackButton: true),
      ),
    ],
  );
}
