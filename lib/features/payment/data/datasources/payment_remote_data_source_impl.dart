import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/user_helpers.dart';
import '../../domain/entities/payment_method.dart';
import '../models/payment_method_model.dart';
import '../models/payment_model.dart';
import 'payment_remote_data_source.dart';

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final SupabaseClient supabaseClient;

  PaymentRemoteDataSourceImpl({required this.supabaseClient});

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
    try {
      final dbUserId = await getUserIdFromAuth(supabaseClient, userId);
      // Detect card brand from card number
      final cardBrand = _detectCardBrand(cardNumber);
      final lastFourDigits = cardNumber.substring(cardNumber.length - 4);

      // If this is default, unset others first
      if (isDefault) {
        await supabaseClient
            .from('payment_methods')
            .update({'is_default': false})
            .eq('user_id', dbUserId);
      }

      final response = await supabaseClient
          .from('payment_methods')
          .insert({
            'user_id': dbUserId,
            'type': type == PaymentMethodType.card
                ? 'card'
                : type == PaymentMethodType.bankAccount
                    ? 'bank_transfer'
                    : 'mobile_money',
            'provider': 'stripe',
            'card_brand': cardBrand,
            'last_four_digits': lastFourDigits,
            'card_holder_name': cardHolderName,
            'expiry_month': expiryMonth,
            'expiry_year': expiryYear,
            'is_default': isDefault,
          })
          .select()
          .single();

      return PaymentMethodModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  String _detectCardBrand(String cardNumber) {
    final cleanNumber = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (cleanNumber.startsWith('4')) {
      return 'Visa';
    } else if (cleanNumber.startsWith('5') ||
        (int.tryParse(cleanNumber.substring(0, 4)) ?? 0) >= 2221 &&
            (int.tryParse(cleanNumber.substring(0, 4)) ?? 0) <= 2720) {
      return 'Mastercard';
    } else if (cleanNumber.startsWith('34') || cleanNumber.startsWith('37')) {
      return 'Amex';
    } else if (cleanNumber.startsWith('6011') ||
        cleanNumber.startsWith('65') ||
        cleanNumber.startsWith('644') ||
        cleanNumber.startsWith('645') ||
        cleanNumber.startsWith('646') ||
        cleanNumber.startsWith('647') ||
        cleanNumber.startsWith('648') ||
        cleanNumber.startsWith('649')) {
      return 'Discover';
    }
    return 'Card';
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
    try {
      final dbUserId = await getUserIdFromAuth(supabaseClient, userId);
      final parsedPaymentMethodId = int.tryParse(paymentMethodId);
      final parsedReservationId = int.tryParse(reservationId ?? '');
      final parsedSessionId = int.tryParse(parkingSessionId ?? '');
      // Create payment record
      final response = await supabaseClient
          .from('payments')
          .insert({
            'user_id': dbUserId,
            'payment_method_id': parsedPaymentMethodId,
            'payment_method': parsedPaymentMethodId != null
                ? 'card'
                : paymentMethodId,
            'amount': amount.round(),
            'currency': 'LKR',
            'payment_status': 'pending',
            'reservation_id': parsedReservationId ?? reservationId,
            'session_id': parsedSessionId ?? parkingSessionId,
          })
          .select()
          .single();

      // In real implementation, this would call a payment gateway
      // For now, simulate successful payment
      final completedResponse = await supabaseClient
          .from('payments')
          .update({
            'payment_status': 'completed',
            'transaction_ref': 'TXN_${DateTime.now().millisecondsSinceEpoch}',
          })
          .eq('id', response['id'])
          .select()
          .single();

      return PaymentModel.fromJson(completedResponse);
    } catch (e) {
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
