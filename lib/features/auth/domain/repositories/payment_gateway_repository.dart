
import 'package:dartz/dartz.dart';
import '../entities/payment_provider.dart';
import '../../../../core/errors/failures.dart';

abstract class PaymentGatewayRepository {
  Future<Either<Failure, PaymentResult>> processPayment({
    required PaymentProvider provider,
    required double amount,
    required String currency,
    required String description,
  });
}
