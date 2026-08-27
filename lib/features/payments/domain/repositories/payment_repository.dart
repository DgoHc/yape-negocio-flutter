import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../notifications/domain/entities/payment_data.dart';

abstract class PaymentRepository {
  Future<Either<Failure, List<PaymentData>>> getPayments();
  Future<Either<Failure, void>> savePayment(PaymentData payment);
  Future<Either<Failure, void>> syncPayments();
  Future<Either<Failure, void>> clearOldPayments(int days);
  Stream<PaymentData> get onPaymentReceived;
  Stream<String> get onRawNotificationReceived;
}
