import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/user_helpers.dart';
import '../../../../core/env/supabase.dart' as app_env;
import '../../../../core/env/stripe.dart';
import '../../domain/entities/payment_method.dart';
import '../models/payment_method_model.dart';
import '../models/payment_model.dart';
import 'payment_remote_data_source.dart';

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final SupabaseClient supabaseClient;

  PaymentRemoteDataSourceImpl({required this.supabaseClient});

  static final RegExp _uuidRegex = RegExp(
    r'^[0-9a-fA-F]{8}-'
    r'[0-9a-fA-F]{4}-'
    r'[0-9a-fA-F]{4}-'
    r'[0-9a-fA-F]{4}-'
    r'[0-9a-fA-F]{12}$',
  );

  static bool _looksLikeUuid(String value) => _uuidRegex.hasMatch(value);

  /// Converts app-level IDs to a DB-friendly type.
  ///
  /// - If it's an int, return int.
  /// - If it's a UUID, return the string.
  /// - Otherwise return null.
  static dynamic _dbIdValue(String? id) {
    if (id == null) return null;
    final trimmed = id.trim();
    if (trimmed.isEmpty) return null;
    final parsedInt = int.tryParse(trimmed);
    if (parsedInt != null) return parsedInt;
    if (_looksLikeUuid(trimmed)) return trimmed;
    return null;
  }

  static String _formatPostgrestError(PostgrestException e) {
    final code = e.code;
    final message = e.message;
    final details = e.details;
    final hint = e.hint;
    return [
      if (code != null && code.toString().isNotEmpty) 'code=$code',
      if (message.isNotEmpty) message,
      if (details != null && details.toString().isNotEmpty) 'details=$details',
      if (hint != null && hint.toString().isNotEmpty) 'hint=$hint',
    ].join(' | ');
  }

  static String? _unknownColumnFromPgrst204(PostgrestException e) {
    // Typical message:
    // "Could not find the 'failure_reason' column of 'payments' in the schema cache"
    final message = e.message;
    final match = RegExp(r"Could not find the '([^']+)' column").firstMatch(message);
    return match?.group(1);
  }

  static String? _jwtIssuer(String jwt) {
    // JWT format: header.payload.signature (base64url)
    final parts = jwt.split('.');
    if (parts.length < 2) return null;
    try {
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final bytes = base64Url.decode(normalized);
      final decoded = utf8.decode(bytes);
      final map = jsonDecode(decoded);
      if (map is Map && map['iss'] is String) return map['iss'] as String;
    } catch (_) {
      // ignore
    }
    return null;
  }

  Future<void> _safeUpdatePaymentsRow({
    required dynamic paymentId,
    required Map<String, dynamic> update,
  }) async {
    // Best-effort update that tolerates schema differences (unknown columns).
    final pending = Map<String, dynamic>.from(update);
    for (var i = 0; i < 5; i++) {
      if (pending.isEmpty) return;
      try {
        await supabaseClient.from('payments').update(pending).eq('id', paymentId);
        return;
      } on PostgrestException catch (e) {
        if (e.code != 'PGRST204') rethrow;
        final unknown = _unknownColumnFromPgrst204(e);
        if (unknown == null || !pending.containsKey(unknown)) {
          // Can't safely recover.
          rethrow;
        }
        pending.remove(unknown);
      }
    }
  }

  Future<dynamic> _ensureCardPaymentMethodId({
    required dynamic dbUserId,
  }) async {
    // Prefer an existing (default/most-recent) payment method.
    final existing = await supabaseClient
        .from('payment_methods')
        .select('id')
        .eq('user_id', dbUserId)
        .order('is_default', ascending: false)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (existing != null && existing['id'] != null) {
      return existing['id'];
    }

    // If none exist, create a non-sensitive placeholder so DB constraints like
    // "card payments must have payment_method_id" can still be satisfied.
    final inserted = await supabaseClient
        .from('payment_methods')
        .insert({
          'user_id': dbUserId,
          'type': 'card',
          'card_brand': 'stripe',
          'last_four_digits': '0000',
          'card_holder_name': 'Stripe',
          'is_default': false,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        })
        .select('id')
        .single();

    return inserted['id'];
  }

  @override
  Future<List<PaymentMethodModel>> getPaymentMethods(String userId) async {
    try {
      final dbUserId = await getUserIdFromAuth(supabaseClient, userId);
      final response = await supabaseClient
          .from('payment_methods')
          .select()
          .eq('user_id', dbUserId)
          .order('is_default', ascending: false)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => PaymentMethodModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<PaymentMethodModel> addPaymentMethod({
    required String userId,
    required PaymentMethodType type,
    required String cardNumber,
    required String cardHolderName,
    required int expiryMonth,
    required int expiryYear,
    required String cvv,
    bool isDefault = false,
  }) async {
    throw const ServerException(
      'Saving card details is disabled. Use Stripe checkout to pay securely.',
    );
  }

  @override
  Future<void> deletePaymentMethod(String paymentMethodId) async {
    try {
      final parsedId = int.tryParse(paymentMethodId) ?? paymentMethodId;
      await supabaseClient
          .from('payment_methods')
          .delete()
          .eq('id', parsedId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<PaymentMethodModel> setDefaultPaymentMethod({
    required String userId,
    required String paymentMethodId,
  }) async {
    try {
      final parsedId = int.tryParse(paymentMethodId) ?? paymentMethodId;
      final dbUserId = await getUserIdFromAuth(supabaseClient, userId);
      // Unset all other defaults
      await supabaseClient
          .from('payment_methods')
          .update({'is_default': false})
          .eq('user_id', dbUserId);

      // Set this one as default
      final response = await supabaseClient
          .from('payment_methods')
          .update({
            'is_default': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', parsedId)
          .select()
          .single();

      return PaymentMethodModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<PaymentModel> processPayment({
    required String userId,
    required String paymentMethodId,
    required double amount,
    String? reservationId,
    String? parkingSessionId,
  }) async {
    dynamic insertedPaymentId;
    try {
      final dbUserId = await getUserIdFromAuth(supabaseClient, userId);
      dynamic dbPaymentMethodId = _dbIdValue(paymentMethodId);
      final dbReservationId = _dbIdValue(reservationId) ?? reservationId;
      final dbSessionId = _dbIdValue(parkingSessionId) ?? parkingSessionId;

      final normalizedMethod = paymentMethodId.trim().toLowerCase();
      // Your DB CHECK constraint likely allows only ('card','cash').
      // Stripe is the provider, but the method is still a card payment.
      final dbPaymentMethod = normalizedMethod == 'stripe'
          ? 'card'
          : (normalizedMethod.isEmpty ? 'card' : normalizedMethod);

      // Many DB schemas enforce that card payments must reference a row in
      // `payment_methods`. When the UI passes 'stripe', resolve/create one.
      if (normalizedMethod == 'stripe' || dbPaymentMethod == 'card') {
        try {
          dbPaymentMethodId = await _ensureCardPaymentMethodId(dbUserId: dbUserId);
        } on PostgrestException catch (e) {
          // If RLS blocks creating/reading payment methods, surface a clearer error.
          throw ServerException(
            'Unable to access payment methods (RLS/policy). ${_formatPostgrestError(e)}',
          );
        }
      }

      Future<Map<String, dynamic>> insertPaymentRecord(
        Map<String, dynamic> payload,
      ) async {
        final inserted = await supabaseClient
            .from('payments')
            .insert(payload)
            .select()
            .single();
        return (inserted as Map).cast<String, dynamic>();
      }

      // Create payment record first (so we can link Stripe metadata)
      late final Map<String, dynamic> insertedPayment;
      try {
        insertedPayment = await insertPaymentRecord({
          'user_id': dbUserId,
          'payment_method_id': dbPaymentMethodId,
          // Keep method explicit; some DBs require it for CHECK constraints.
          'payment_method': dbPaymentMethod,
          'amount': amount.round(),
          'currency': 'LKR',
          // Some deployed schemas reject 'processing' (CHECK constraint).
          // Start as 'pending' and move to 'completed'/'failed'.
          'payment_status': 'pending',
          'reservation_id': dbReservationId,
          'session_id': dbSessionId,
        });
      } on PostgrestException catch (e) {
        if (e.code == '23514') {
          throw ServerException(
            "DB CHECK constraint rejected the payment insert. "
            "payment_method='$dbPaymentMethod', payment_status='pending'. "
            "${_formatPostgrestError(e)}",
          );
        }
        throw ServerException(_formatPostgrestError(e));
      }

      insertedPaymentId = insertedPayment['id'];

      final amountMinor = (amount * 100).round();

      final invokeBody = {
        'amount': amountMinor,
        'currency': 'lkr',
        'metadata': {
          'payment_id': insertedPayment['id'].toString(),
          if (reservationId != null) 'reservation_id': reservationId,
          if (parkingSessionId != null) 'parking_session_id': parkingSessionId,
          'user_id': userId,
        },
      };

      // Edge Functions commonly require a valid Supabase Auth JWT.
      // If the access token expired, refresh it once before invoking.
      String? accessToken;
      try {
        final session = supabaseClient.auth.currentSession;
        if (session == null) {
          throw const ServerException(
            'You are not signed in. Please sign in again and retry payment.',
          );
        }
        // Use the current token as a fallback in case refresh fails.
        accessToken = session.accessToken;
        await supabaseClient.auth.refreshSession();
        accessToken = supabaseClient.auth.currentSession?.accessToken ?? accessToken;
      } catch (e) {
        if (e is ServerException) rethrow;
        // If refresh fails, proceed; the invoke handler below will surface 401.
      }

      // Some setups (notably with publishable keys) may not attach the user JWT
      // to Edge Function calls automatically. Provide it explicitly.
      // Also include `apikey` explicitly. Depending on the client version,
      // providing custom headers can override defaults and accidentally drop it.
      final functionHeaders = <String, String>{
        'apikey': app_env.supabaseKey,
        if (accessToken != null && accessToken.isNotEmpty)
          'Authorization': 'Bearer $accessToken',
      };

      // Your Supabase dashboard shows a function named `create-payment-intent`.
      // Older app code used `create-stripe-payment-intent`. Try both to avoid 404.
      dynamic functionResponse;
      Object? lastInvokeError;
      for (final fnName in const [
        'create-payment-intent',
        'create-stripe-payment-intent',
      ]) {
        try {
          functionResponse = await supabaseClient.functions.invoke(
            fnName,
            body: invokeBody,
            headers: functionHeaders,
          );
          lastInvokeError = null;
          break;
        } on FunctionException catch (e) {
          lastInvokeError = e;
          if (e.status == 401) {
            // Supabase returns "Invalid JWT" when no/expired token is provided.
            final issuer = accessToken == null ? null : _jwtIssuer(accessToken);
            final issuerHint = issuer == null ? '' : ' token_iss=$issuer';
            final configuredProject = app_env.supabaseUrl;
            final configuredHint = ' configured_supabase_url=$configuredProject';
            final sameProject = issuer != null && issuer.contains(configuredProject);
            throw ServerException(
              'Unauthorized (Invalid JWT).$issuerHint$configuredHint\n'
              '${sameProject ? 'JWT issuer matches the configured project. ' : ''}'
              'Check that the app uses the Anon public key (eyJ...) for this project, then sign out/in and retry. '
              'If it still fails, disable "Verify JWT" for the Edge Function (or redeploy with no-verify-jwt).',
            );
          }
          final msg = e.toString().toLowerCase();
          final looksLikeNotFound = msg.contains('requested function not found') ||
              msg.contains('function not found') ||
              msg.contains('404');
          if (!looksLikeNotFound) rethrow;
        } catch (e) {
          lastInvokeError = e;
          final msg = e.toString().toLowerCase();
          final looksLikeNotFound = msg.contains('requested function not found') ||
              msg.contains('function not found') ||
              msg.contains('404');
          if (!looksLikeNotFound) rethrow;
        }
      }

      if (functionResponse == null) {
        final message =
            'Supabase Edge Function not found. Deploy/rename it to `create-payment-intent` '
            'or update the app to match. ${lastInvokeError ?? ''}'.trim();
        try {
          await _safeUpdatePaymentsRow(
            paymentId: insertedPayment['id'],
            update: {'payment_status': 'failed', 'failure_reason': message},
          );
        } catch (_) {}
        throw ServerException(message);
      }

      final dynamic responseData = (functionResponse as dynamic).data;
      if (responseData == null) {
        final message =
            'Failed to create PaymentIntent (no response data). Check Edge Function logs in Supabase.';
        try {
          await _safeUpdatePaymentsRow(
            paymentId: insertedPayment['id'],
            update: {'payment_status': 'failed', 'failure_reason': message},
          );
        } catch (_) {}
        throw ServerException(message);
      }

      Map<String, dynamic> data;
      if (responseData is Map) {
        data = responseData.cast<String, dynamic>();
      } else {
        final message =
            'Unexpected Edge Function response type: ${responseData.runtimeType}. Expected JSON object.';
        try {
          await _safeUpdatePaymentsRow(
            paymentId: insertedPayment['id'],
            update: {'payment_status': 'failed', 'failure_reason': message},
          );
        } catch (_) {}
        throw ServerException(message);
      }

      final serverError = data['error'] ?? data['message'] ?? data['details'];
      if (serverError != null) {
        final message = serverError.toString();
        try {
          await _safeUpdatePaymentsRow(
            paymentId: insertedPayment['id'],
            update: {'payment_status': 'failed', 'failure_reason': message},
          );
        } catch (_) {}
        throw ServerException(message);
      }

      final clientSecret =
          (data['clientSecret'] ?? data['client_secret'] ?? data['payment_intent_client_secret'])
              as String?;
      final paymentIntentId =
          (data['paymentIntentId'] ?? data['payment_intent_id'] ?? data['id']) as String?;

      if (clientSecret == null || clientSecret.isEmpty) {
        const message = 'Missing clientSecret from server';
        try {
          await _safeUpdatePaymentsRow(
            paymentId: insertedPayment['id'],
            update: {'payment_status': 'failed', 'failure_reason': message},
          );
        } catch (_) {}
        throw const ServerException(message);
      }

      await stripe.Stripe.instance.initPaymentSheet(
        paymentSheetParameters: stripe.SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: stripeMerchantDisplayName,
        ),
      );

      await stripe.Stripe.instance.presentPaymentSheet();

      // Best-effort completion update; tolerate differing column names.
      try {
        await _safeUpdatePaymentsRow(
          paymentId: insertedPayment['id'],
          update: {
            'payment_status': 'completed',
            if (paymentIntentId != null) 'transaction_ref': paymentIntentId,
            'completed_at': DateTime.now().toIso8601String(),
          },
        );
      } catch (_) {}

      final completedResponse = await supabaseClient
          .from('payments')
          .select()
          .eq('id', insertedPayment['id'])
          .single();

      return PaymentModel.fromJson(completedResponse);
    } on PostgrestException catch (e) {
      if (insertedPaymentId != null) {
        try {
          await _safeUpdatePaymentsRow(
            paymentId: insertedPaymentId,
            update: {
              'payment_status': 'failed',
              'failure_reason': _formatPostgrestError(e),
            },
          );
        } catch (_) {}
      }
      throw ServerException(_formatPostgrestError(e));
    } on stripe.StripeException catch (e) {
      final message = e.error.localizedMessage ?? 'Payment cancelled';
      if (insertedPaymentId != null) {
        try {
          await _safeUpdatePaymentsRow(
            paymentId: insertedPaymentId,
            update: {'payment_status': 'failed', 'failure_reason': message},
          );
        } catch (_) {}
      }
      throw ServerException(message);
    } catch (e) {
      if (insertedPaymentId != null) {
        try {
          await _safeUpdatePaymentsRow(
            paymentId: insertedPaymentId,
            update: {'payment_status': 'failed', 'failure_reason': e.toString()},
          );
        } catch (_) {}
      }
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<PaymentModel>> getPaymentHistory(String userId) async {
    try {
      final dbUserId = await getUserIdFromAuth(supabaseClient, userId);
      final response = await supabaseClient
          .from('payments')
          .select()
          .eq('user_id', dbUserId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => PaymentModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<PaymentModel> getPaymentById(String paymentId) async {
    try {
      final response = await supabaseClient
          .from('payments')
          .select()
          .eq('id', paymentId)
          .single();

      return PaymentModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
