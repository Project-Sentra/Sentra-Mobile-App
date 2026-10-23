import 'package:equatable/equatable.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/entities/wallet_transaction.dart';

enum WalletStatus { initial, loading, loaded, toppingUp, topUpSuccess, error }

class WalletState extends Equatable {
  final WalletStatus status;
  final Wallet? wallet;
  final List<WalletTransaction> transactions;
  final String? errorMessage;
  final String? successMessage;

  const WalletState({
    this.status = WalletStatus.initial,
    this.wallet,
    this.transactions = const [],
    this.errorMessage,
    this.successMessage,
  });

  WalletState copyWith({
    WalletStatus? status,
    Wallet? wallet,
    List<WalletTransaction>? transactions,
    String? errorMessage,
    String? successMessage,
  }) {
    return WalletState(
      status: status ?? this.status,
      wallet: wallet ?? this.wallet,
      transactions: transactions ?? this.transactions,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        wallet,
        transactions,
        errorMessage,
        successMessage,
      ];
}
