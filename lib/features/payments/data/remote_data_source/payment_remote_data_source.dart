
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../dtos/payment_dto.dart';

abstract class PaymentRemoteDataSource {
  Future<Either<Failure, PaymentDto>> createPayment(PaymentDto dto);
  Future<Either<Failure, List<PaymentDto>>> getPayments();
}

@LazySingleton(as: PaymentRemoteDataSource)
class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final Dio _dio;

  PaymentRemoteDataSourceImpl(this._dio);

  @override
  Future<Either<Failure, PaymentDto>> createPayment(PaymentDto dto) async {
    try {
      final response = await _dio.post(
        '/payments',
        data: dto.toJson(),
      );

      return Right(PaymentDto.fromJson(response.data));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PaymentDto>>> getPayments() async {
    try {
      final response = await _dio.get('/payments');
      final List<dynamic> data = response.data;
      final List<PaymentDto> payments = data.map((json) => PaymentDto.fromJson(json)).toList();
      return Right(payments);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
