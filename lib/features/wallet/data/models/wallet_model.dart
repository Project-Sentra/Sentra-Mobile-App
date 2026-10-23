import '../../domain/entities/wallet.dart';

class WalletModel extends Wallet {
  const WalletModel({
    required super.id,
    required super.userId,
    required super.balance,
    super.currency,
    required super.updatedAt,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: (json['id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      balance: (json['balance'] as num).toInt(),
      currency: json['currency'] as String? ?? 'LKR',
      updatedAt: DateTime.parse(
        json['updated_at']?.toString() ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'balance': balance,
        'currency': currency,
        'updated_at': updatedAt.toIso8601String(),
      };
}
