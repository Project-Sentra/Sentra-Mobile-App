import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/env/stripe.dart';
import '../../../../core/env/supabase.dart' as app_env;
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/user_helpers.dart';
import '../models/wallet_model.dart';
import '../models/wallet_transaction_model.dart';

abstract class WalletRemoteDataSource {
  Future<WalletModel> getWallet();
  Future<WalletModel> topUpWallet({required double amount});
  Future<List<WalletTransactionModel>> getTransactions();
}

class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final SupabaseClient supabaseClient;

  WalletRemoteDataSourceImpl({required this.supabaseClient});

  Future<int> _getCurrentDbUserId() async {
    final authUser = supabaseClient.auth.currentUser;
    if (authUser == null) {
      throw const ServerException('User not authenticated');
    }
    return getUserIdFromAuth(supabaseClient, authUser.id);
  }

  @override
  Future<WalletModel> getWallet() async {
    try {
      final dbUserId = await _getCurrentDbUserId();
      final response = await supabaseClient
          .from('user_wallets')
          .select()
          .eq('user_id', dbUserId)
          .maybeSingle();

      if (response != null) {
        return WalletModel.fromJson(response);
      }

      // Auto-initialize wallet row if not exists
      final created = await supabaseClient
          .from('user_wallets')
          .insert({'user_id': dbUserId, 'balance': 0, 'currency': 'LKR'})
          .select()
          .single();

      return WalletModel.fromJson(created);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<WalletModel> topUpWallet({required double amount}) async {
    try {
      final dbUserId = await _getCurrentDbUserId();
      final authUserId = supabaseClient.auth.currentUser!.id;

      // 1. Invoke Edge Function for Stripe PaymentIntent
      final amountMinor = (amount * 100).round();
      final functionHeaders = <String, String>{
        'apikey': app_env.supabaseKey,
        if (supabaseClient.auth.currentSession?.accessToken != null)
          'Authorization': 'Bearer ${supabaseClient.auth.currentSession!.accessToken}',
      };

      dynamic functionResponse;
      for (final fnName in const [
        'create-payment-intent',
        'create-stripe-payment-intent',
      ]) {
        try {
          functionResponse = await supabaseClient.functions.invoke(
            fnName,
            body: {
              'amount': amountMinor,
              'currency': 'lkr',
              'metadata': {'user_id': authUserId, 'type': 'wallet_topup'},
            },
            headers: functionHeaders,
          );
          break;
        } catch (_) {}
      }

      if (functionResponse == null || functionResponse.data == null) {
        throw const ServerException('Failed to initialize payment gateway');
      }

      final dynamic resData = functionResponse.data;
      Map<String, dynamic> data;
      if (resData is Map) {
        data = resData.cast<String, dynamic>();
      } else {
        throw const ServerException('Unexpected response from payment server');
      }

      final clientSecret = (data['clientSecret'] ??
          data['client_secret'] ??
          data['payment_intent_client_secret']) as String?;
      final paymentIntentId =
          (data['paymentIntentId'] ?? data['payment_intent_id'] ?? data['id'])
              as String?;

      if (clientSecret == null || clientSecret.isEmpty) {
        throw const ServerException('Missing payment secret from server');
      }

      // 2. Present Native Stripe Sheet
      await stripe.Stripe.instance.initPaymentSheet(
        paymentSheetParameters: stripe.SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: stripeMerchantDisplayName,
        ),
      );
      await stripe.Stripe.instance.presentPaymentSheet();

      // 3. Fetch current wallet balance & credit
      final currentWallet = await getWallet();
      final newBalance = currentWallet.balance + amount.round();

      final updated = await supabaseClient
          .from('user_wallets')
          .update({
            'balance': newBalance,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', dbUserId)
          .select()
          .single();

      // 4. Record payment log
      try {
        await supabaseClient.from('payments').insert({
          'user_id': dbUserId,
          'amount': amount.round(),
          'currency': 'LKR',
          'payment_method': 'card',
          'payment_status': 'completed',
          'description': 'Stripe Wallet Top-up',
          'transaction_ref': paymentIntentId,
        });
      } catch (_) {}

      // 5. Send notification
      try {
        await supabaseClient.from('notifications').insert({
          'user_id': dbUserId,
          'title': 'Wallet Topped Up',
          'message':
              'LKR ${amount.round()} added to your wallet. New balance: LKR $newBalance.',
          'type': 'payment',
          'is_read': false,
        });
      } catch (_) {}

      return WalletModel.fromJson(updated);
    } on stripe.StripeException catch (e) {
      throw ServerException(e.error.localizedMessage ?? 'Payment cancelled');
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<WalletTransactionModel>> getTransactions() async {
    try {
      final dbUserId = await _getCurrentDbUserId();
      final response = await supabaseClient
          .from('payments')
          .select()
          .eq('user_id', dbUserId)
          .order('created_at', ascending: false)
          .limit(50);

      return (response as List)
          .map((json) => WalletTransactionModel.fromJson(json))
          .toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
