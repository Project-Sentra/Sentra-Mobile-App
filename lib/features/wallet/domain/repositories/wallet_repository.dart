import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/wallet.dart';
import '../entities/wallet_transaction.dart';

abstract class WalletRepository {
  Future<Either<Failure, Wallet>> getWallet();
  Future<Either<Failure, Wallet>> topUpWallet({required double amount});
  Future<Either<Failure, List<WalletTransaction>>> getTransactions();
}
