import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../parking/domain/entities/parking_receipt.dart';
import '../repositories/history_repository.dart';

class GetReceiptsUseCase implements UseCase<List<ParkingReceipt>, String> {
  final HistoryRepository repository;

  GetReceiptsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ParkingReceipt>>> call(String userId) {
    return repository.getReceipts(userId);
  }
}
