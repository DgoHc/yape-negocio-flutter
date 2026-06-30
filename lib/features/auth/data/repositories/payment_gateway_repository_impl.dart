import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/payment_provider.dart';
import '../../domain/repositories/payment_gateway_repository.dart';
import 'package:url_launcher/url_launcher.dart';

@Injectable(as: PaymentGatewayRepository)
class PaymentGatewayRepositoryImpl implements PaymentGatewayRepository {
  final Dio _dio;

  PaymentGatewayRepositoryImpl(this._dio);

  @override
  Future<Either<Failure, PaymentResult>> processPayment({
    required PaymentProvider provider,
    required double amount,
    required String currency,
    required String description,
  }) async {
    try {
      AppLogger.i('Procesando pago con $provider por $amount $currency');
      switch (provider) {
        case PaymentProvider.culqi:
          return await _processCulqiPayment(amount, currency, description).timeout(const Duration(seconds: 15));
        case PaymentProvider.mercadoPago:
          return await _processMercadoPagoPayment(amount, currency, description).timeout(const Duration(seconds: 15));
        case PaymentProvider.yape:
          return await _processYapePayment(amount, currency, description).timeout(const Duration(seconds: 15));
      }
    } on DioException catch (e) {
      AppLogger.e('Error de Dio en processPayment', e);
      return Left(ServerFailure(_extractErrorMessage(e)));
    } catch (e) {
      AppLogger.e('Error inesperado en processPayment', e);
      return Left(ServerFailure('Error al procesar pago: $e'));
    }
  }

  String _extractErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data != null && data is Map) {
      return data['error']?.toString() ?? data['message']?.toString() ?? e.message ?? 'Error del servidor';
    }
    if (data != null && data is String && data.isNotEmpty) {
      return data;
    }
    return e.message ?? 'Error de conexión con el servidor de pagos';
  }

  Future<Either<Failure, PaymentResult>> _processCulqiPayment(
    double amount,
    String currency,
    String description,
  ) async {
    final response = await _dio.post('/payments/culqi', data: {
      'amount': (amount * 100).toInt(),
      'currency': currency,
      'description': description,
    });

    final data = response.data;
    if (data is! Map) throw Exception('Respuesta de Culqi inválida');

    final paymentUrl = data['payment_url'] as String?;
    if (paymentUrl != null && await canLaunchUrl(Uri.parse(paymentUrl))) {
      await launchUrl(
        Uri.parse(paymentUrl),
        mode: LaunchMode.externalApplication,
      );
    }

    return Right(PaymentResult(
      success: true,
      transactionId: data['id']?.toString(),
      provider: PaymentProvider.culqi,
    ));
  }

  Future<Either<Failure, PaymentResult>> _processMercadoPagoPayment(
    double amount,
    String currency,
    String description,
  ) async {
    final response = await _dio.post('/payments/mercadopago', data: {
      'amount': amount,
      'currency': currency,
      'description': description,
    });

    final data = response.data;
    if (data is! Map) throw Exception('Respuesta de Mercado Pago inválida');

    final paymentUrl = data['init_point'] as String?;
    if (paymentUrl != null && await canLaunchUrl(Uri.parse(paymentUrl))) {
      await launchUrl(
        Uri.parse(paymentUrl),
        mode: LaunchMode.externalApplication,
      );
    }

    return Right(PaymentResult(
      success: true,
      transactionId: data['id']?.toString(),
      provider: PaymentProvider.mercadoPago,
    ));
  }

  Future<Either<Failure, PaymentResult>> _processYapePayment(
    double amount,
    String currency,
    String description,
  ) async {
    final response = await _dio.post('/payments/yape', data: {
      'amount': amount,
      'currency': currency,
      'description': description,
    });

    final data = response.data;
    if (data is! Map) throw Exception('Respuesta de Yape inválida');

    final paymentUrl = data['payment_url'] as String?;
    if (paymentUrl != null && paymentUrl.isNotEmpty) {
      if (await canLaunchUrl(Uri.parse(paymentUrl))) {
        await launchUrl(
          Uri.parse(paymentUrl),
          mode: LaunchMode.externalApplication,
        );
      }
    }

    return Right(PaymentResult(
      success: true,
      transactionId: data['id']?.toString(),
      provider: PaymentProvider.yape,
    ));
  }
}
