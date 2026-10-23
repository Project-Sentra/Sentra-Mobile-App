import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/wallet.dart';
import '../repositories/wallet_repository.dart';

class GetWalletUseCase implements UseCase<Wallet, NoParams> {
  final WalletRepository repository;

  GetWalletUseCase(this.repository);

  @override
  Future<Either<Failure, Wallet>> call(NoParams params) {
    return repository.getWallet();
  }
}
