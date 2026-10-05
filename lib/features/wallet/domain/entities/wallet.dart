import 'package:equatable/equatable.dart';

class Wallet extends Equatable {
  final int id;
  final int userId;
  final int balance;
  final String currency;
  final DateTime updatedAt;

  const Wallet({
    required this.id,
    required this.userId,
    required this.balance,
    this.currency = 'LKR',
    required this.updatedAt,
  });

  String get formattedBalance => '$currency ${balance.toString()}';

  @override
  List<Object?> get props => [id, userId, balance, currency, updatedAt];
}
