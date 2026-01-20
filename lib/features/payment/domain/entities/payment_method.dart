import 'package:equatable/equatable.dart';

enum PaymentMethodType { card, bankAccount, mobileMoney }

class PaymentMethod extends Equatable {
  final String id;
  final String userId;
  final PaymentMethodType type;
  final String? cardBrand; // Visa, Mastercard, etc.
  final String lastFourDigits;
  final String? cardHolderName;
  final int? expiryMonth;
  final int? expiryYear;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const PaymentMethod({
    required this.id,
    required this.userId,
    required this.type,
    this.cardBrand,
    required this.lastFourDigits,
    this.cardHolderName,
    this.expiryMonth,
    this.expiryYear,
    this.isDefault = false,
    required this.createdAt,
    this.updatedAt,
  });

  String get displayName {
    if (type == PaymentMethodType.card) {
      return '${cardBrand ?? 'Card'} •••• $lastFourDigits';
    }
    return 'Account •••• $lastFourDigits';
  }

  bool get isExpired {
    if (expiryMonth == null || expiryYear == null) return false;
    final now = DateTime.now();
    final expiry = DateTime(expiryYear!, expiryMonth!);
    return now.isAfter(expiry);
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    type,
    cardBrand,
    lastFourDigits,
    cardHolderName,
    expiryMonth,
    expiryYear,
    isDefault,
    createdAt,
    updatedAt,
  ];

  PaymentMethod copyWith({
    String? id,
    String? userId,
    PaymentMethodType? type,
    String? cardBrand,
    String? lastFourDigits,
    String? cardHolderName,
    int? expiryMonth,
    int? expiryYear,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      cardBrand: cardBrand ?? this.cardBrand,
      lastFourDigits: lastFourDigits ?? this.lastFourDigits,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      expiryMonth: expiryMonth ?? this.expiryMonth,
      expiryYear: expiryYear ?? this.expiryYear,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
