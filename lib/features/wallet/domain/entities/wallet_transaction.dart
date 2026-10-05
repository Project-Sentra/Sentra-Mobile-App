import 'package:equatable/equatable.dart';

class WalletTransaction extends Equatable {
  final int id;
  final int amount;
  final String type; // 'credit' (top-up) or 'debit' (parking fee)
  final String description;
  final String status; // 'completed', 'pending', 'failed'
  final String? transactionRef;
  final DateTime createdAt;

  const WalletTransaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.description,
    required this.status,
    this.transactionRef,
    required this.createdAt,
  });

  bool get isCredit => type == 'credit';

  String get formattedAmount =>
      isCredit ? '+LKR $amount' : '-LKR $amount';

  @override
  List<Object?> get props => [
        id,
        amount,
        type,
        description,
        status,
        transactionRef,
        createdAt,
      ];
}
