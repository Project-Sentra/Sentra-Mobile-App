import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_wallet_transactions_usecase.dart';
import '../../domain/usecases/get_wallet_usecase.dart';
import '../../domain/usecases/top_up_wallet_usecase.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final GetWalletUseCase getWalletUseCase;
  final TopUpWalletUseCase topUpWalletUseCase;
  final GetWalletTransactionsUseCase getWalletTransactionsUseCase;

  WalletBloc({
    required this.getWalletUseCase,
    required this.topUpWalletUseCase,
    required this.getWalletTransactionsUseCase,
  }) : super(const WalletState()) {
    on<FetchWalletData>(_onFetchWalletData);
    on<TopUpWallet>(_onTopUpWallet);
  }

  Future<void> _onFetchWalletData(
    FetchWalletData event,
    Emitter<WalletState> emit,
  ) async {
    emit(state.copyWith(status: WalletStatus.loading));

    final walletResult = await getWalletUseCase(const NoParams());
    final txResult = await getWalletTransactionsUseCase(const NoParams());

    walletResult.fold(
      (failure) => emit(
        state.copyWith(
          status: WalletStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (wallet) {
        final transactions = txResult.getOrElse(() => []);
        emit(
          state.copyWith(
            status: WalletStatus.loaded,
            wallet: wallet,
            transactions: transactions,
          ),
        );
      },
    );
  }

  Future<void> _onTopUpWallet(
    TopUpWallet event,
    Emitter<WalletState> emit,
  ) async {
    emit(state.copyWith(status: WalletStatus.toppingUp));

    final result = await topUpWalletUseCase(event.amount);

    await result.fold(
      (failure) async {
        emit(
          state.copyWith(
            status: WalletStatus.error,
            errorMessage: failure.message,
          ),
        );
      },
      (updatedWallet) async {
        final txResult = await getWalletTransactionsUseCase(const NoParams());
        final transactions = txResult.getOrElse(() => state.transactions);

        emit(
          state.copyWith(
            status: WalletStatus.topUpSuccess,
            wallet: updatedWallet,
            transactions: transactions,
            successMessage:
                'Successfully added LKR ${event.amount.toStringAsFixed(0)} to wallet!',
          ),
        );
      },
    );
  }
}
