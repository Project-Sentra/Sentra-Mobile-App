import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/wallet.dart';
import '../repositories/wallet_repository.dart';

class TopUpWalletUseCase implements UseCase<Wallet, double> {
  final WalletRepository repository;

  TopUpWalletUseCase(this.repository);

  @override
  Future<Either<Failure, Wallet>> call(double amount) {
    return repository.topUpWallet(amount: amount);
  }
}
