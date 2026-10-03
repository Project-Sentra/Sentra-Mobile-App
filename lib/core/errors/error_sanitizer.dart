import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Centralized utility to sanitize low-level exceptions, database codes,
/// and network errors into clean, human-friendly messages for the UI.
class ErrorSanitizer {
  ErrorSanitizer._();

  /// Converts any exception, failure, or raw error object into a concise,
  /// user-friendly message suitable for display in UI SnackBars or banners.
  static String sanitize(dynamic error) {
    if (error == null) {
      return 'An unexpected error occurred. Please try again.';
    }

    final message = error is String ? error : error.toString();
    final lower = message.toLowerCase();

    // 1. Network & Connectivity Errors
    if (lower.contains('socketexception') ||
        lower.contains('clientexception') ||
        lower.contains('failed host lookup') ||
        lower.contains('network is unreachable') ||
        lower.contains('connection timed out') ||
        lower.contains('connection refused') ||
        lower.contains('handshakeexception') ||
        lower.contains('no address associated with hostname')) {
      return 'Unable to connect to the server. Please check your internet connection.';
    }

    // 2. Authentication Errors
    if (lower.contains('invalid login credentials') ||
        lower.contains('invalid_credentials') ||
        lower.contains('invalid email or password') ||
        lower.contains('user not found') ||
        lower.contains('invalid_grant')) {
      return 'Invalid email or password. Please verify your credentials.';
    }

    if (lower.contains('email not confirmed')) {
      return 'Please verify your email address before signing in.';
    }

    if (lower.contains('user already registered') ||
        lower.contains('email already exists') ||
        lower.contains('user_already_exists')) {
      return 'An account with this email already exists. Try signing in.';
    }

    if (lower.contains('password should be at least') ||
        lower.contains('weak_password')) {
      return 'Password must be at least 6 characters long.';
    }

    if (lower.contains('google sign in was cancelled') ||
        lower.contains('sign_in_canceled') ||
        lower.contains('canceled by user') ||
        lower.contains('cancelled by user')) {
      return 'Google sign-in was cancelled.';
    }

    if (lower.contains('apple sign in was cancelled')) {
      return 'Apple sign-in was cancelled.';
    }

    if (lower.contains('session expired') || lower.contains('jwt expired')) {
      return 'Your session has expired. Please sign in again.';
    }

    // 3. Database / Supabase Server Errors
    if (lower.contains('postgrestexception') ||
        lower.contains('pgrst') ||
        lower.contains('duplicate key value') ||
        lower.contains('violates foreign key') ||
        lower.contains('violates not-null') ||
        lower.contains('violates check constraint') ||
        lower.contains('permission denied for table') ||
        (lower.contains('relation') && lower.contains('does not exist'))) {
      return 'Server error. Please try again later.';
    }

    // 4. Payment / Stripe Errors
    if (lower.contains('stripeexception') ||
        (lower.contains('payment') && lower.contains('failed'))) {
      return 'Payment processing failed. Please try a different card or method.';
    }
    if (lower.contains('canceled') && lower.contains('payment')) {
      return 'Payment was cancelled.';
    }

    // 5. Booking / Parking Errors
    if (lower.contains('slot already occupied') ||
        lower.contains('spot already reserved') ||
        lower.contains('not available')) {
      return 'This parking spot is no longer available. Please select another.';
    }

    // 6. Clean messages that are already user-facing
    // If it's a short, sentence-like message without tech stack tokens, allow it.
    if (!message.contains('Exception') &&
        !message.contains('Error:') &&
        !message.contains('{') &&
        !message.contains('code=') &&
        !message.contains('PGRST') &&
        message.length < 120) {
      return message;
    }

    return 'Something went wrong. Please try again.';
  }

  /// Convenience method to display a styled error SnackBar with sanitized copy.
  static void showError(BuildContext context, dynamic error) {
    final cleanMessage = sanitize(error);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          cleanMessage,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
