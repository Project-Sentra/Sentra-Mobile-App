import '../../domain/entities/wallet_transaction.dart';

class WalletTransactionModel extends WalletTransaction {
  const WalletTransactionModel({
    required super.id,
    required super.amount,
    required super.type,
    required super.description,
    required super.status,
    super.transactionRef,
    required super.createdAt,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    final method = (json['payment_method'] as String? ?? '').toLowerCase();
    final desc = (json['description'] as String? ?? '').toLowerCase();
    final isTopUp =
        desc.contains('top-up') || desc.contains('top up') || method == 'card';

    return WalletTransactionModel(
      id: (json['id'] as num).toInt(),
      amount: ((json['amount'] as num?)?.toDouble() ?? 0).round(),
      type: isTopUp ? 'credit' : 'debit',
      description: json['description'] as String? ??
          (isTopUp ? 'Wallet Top-up' : 'Parking Payment'),
      status: json['payment_status'] as String? ?? 'completed',
      transactionRef: json['transaction_ref'] as String?,
      createdAt: DateTime.parse(
        json['created_at']?.toString() ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
