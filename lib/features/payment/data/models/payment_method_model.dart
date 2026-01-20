import '../../domain/entities/payment_method.dart';

class PaymentMethodModel extends PaymentMethod {
  const PaymentMethodModel({
    required super.id,
    required super.userId,
    required super.type,
    super.cardBrand,
    required super.lastFourDigits,
    super.cardHolderName,
    super.expiryMonth,
    super.expiryYear,
    super.isDefault,
    required super.createdAt,
    super.updatedAt,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: _parsePaymentMethodType(json['type'] as String),
      cardBrand: json['card_brand'] as String?,
      lastFourDigits: json['last_four_digits'] as String,
      cardHolderName: json['card_holder_name'] as String?,
      expiryMonth: json['expiry_month'] as int?,
      expiryYear: json['expiry_year'] as int?,
      isDefault: json['is_default'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': _paymentMethodTypeToString(type),
      'card_brand': cardBrand,
      'last_four_digits': lastFourDigits,
      'card_holder_name': cardHolderName,
      'expiry_month': expiryMonth,
      'expiry_year': expiryYear,
      'is_default': isDefault,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  static PaymentMethodType _parsePaymentMethodType(String type) {
    switch (type) {
      case 'card':
        return PaymentMethodType.card;
      case 'bank_account':
        return PaymentMethodType.bankAccount;
      case 'mobile_money':
        return PaymentMethodType.mobileMoney;
      default:
        return PaymentMethodType.card;
    }
  }

  static String _paymentMethodTypeToString(PaymentMethodType type) {
    switch (type) {
      case PaymentMethodType.card:
        return 'card';
      case PaymentMethodType.bankAccount:
        return 'bank_account';
      case PaymentMethodType.mobileMoney:
        return 'mobile_money';
    }
  }
}
