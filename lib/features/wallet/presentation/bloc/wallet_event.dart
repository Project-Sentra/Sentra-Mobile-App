import 'package:equatable/equatable.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

class FetchWalletData extends WalletEvent {
  const FetchWalletData();
}

class TopUpWallet extends WalletEvent {
  final double amount;

  const TopUpWallet(this.amount);

  @override
  List<Object?> get props => [amount];
}
