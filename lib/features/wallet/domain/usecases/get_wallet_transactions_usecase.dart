import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/wallet_transaction.dart';
import '../repositories/wallet_repository.dart';

class GetWalletTransactionsUseCase
    implements UseCase<List<WalletTransaction>, NoParams> {
  final WalletRepository repository;

  GetWalletTransactionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<WalletTransaction>>> call(NoParams params) {
    return repository.getTransactions();
  }
}
