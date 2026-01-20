import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_remote_data_source.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource remoteDataSource;

  PaymentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<PaymentMethod>>> getPaymentMethods(
    String userId,
  ) async {
    try {
      final methods = await remoteDataSource.getPaymentMethods(userId);
      return Right(methods);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaymentMethod>> addPaymentMethod({
    required String userId,
    required PaymentMethodType type,
    required String cardNumber,
    required String cardHolderName,
    required int expiryMonth,
    required int expiryYear,
    required String cvv,
    bool isDefault = false,
  }) async {
    try {
      final method = await remoteDataSource.addPaymentMethod(
        userId: userId,
        type: type,
        cardNumber: cardNumber,
        cardHolderName: cardHolderName,
        expiryMonth: expiryMonth,
        expiryYear: expiryYear,
        cvv: cvv,
        isDefault: isDefault,
      );
      return Right(method);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deletePaymentMethod(
    String paymentMethodId,
  ) async {
    try {
      await remoteDataSource.deletePaymentMethod(paymentMethodId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaymentMethod>> setDefaultPaymentMethod({
    required String userId,
    required String paymentMethodId,
  }) async {
    try {
      final method = await remoteDataSource.setDefaultPaymentMethod(
        userId: userId,
        paymentMethodId: paymentMethodId,
      );
      return Right(method);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Payment>> processPayment({
    required String userId,
    required String paymentMethodId,
    required double amount,
    String? reservationId,
    String? parkingSessionId,
  }) async {
    try {
      final payment = await remoteDataSource.processPayment(
        userId: userId,
        paymentMethodId: paymentMethodId,
        amount: amount,
        reservationId: reservationId,
        parkingSessionId: parkingSessionId,
      );
      return Right(payment);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Payment>>> getPaymentHistory(
    String userId,
  ) async {
    try {
      final payments = await remoteDataSource.getPaymentHistory(userId);
      return Right(payments);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Payment>> getPaymentById(String paymentId) async {
    try {
      final payment = await remoteDataSource.getPaymentById(paymentId);
      return Right(payment);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
