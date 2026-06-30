import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/app_logger.dart';
import 'package:injectable/injectable.dart';
import '../entities/payment_data.dart';

@lazySingleton
class PaymentParser {
  /// Regex ultra-flexible para capturar pagos de Yape.
  /// Busca el patrón: [Nombre] + "te envió un pago"
  static final RegExp _yapeRegex = RegExp(
    r"(.+?)\s+te\s+envió\s+un\s+pago\s+por\s+(S/|PEN|S\./)\s*([\d,.]+)",
    caseSensitive: false,
  );

  static Either<Failure, PaymentData> parse(String raw) {
    // Log para ver qué llega al parser en consola de depuración
    AppLogger.d('PARSER INPUT: "$raw"');
    
    if (raw.isEmpty) {
      return const Left(ServerFailure('Texto vacío'));
    }


    final cleanRaw = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
    final match = _yapeRegex.firstMatch(cleanRaw);

    if (match == null) {

      AppLogger.w('PARSER ERROR: No coincide con el formato Yape');
      return const Left(ServerFailure('Formato no reconocido'));
    }

    try {
      final name = (match.group(1) ?? "").trim().replaceAll(RegExp(r'\*$'), '');
      final currency = (match.group(2) ?? "S/").trim();

      final rawAmountStr = match.group(3) ?? "0";
      // Extraer solo caracteres numéricos (dígitos y puntos)
      var amountStr = rawAmountStr.replaceAll(RegExp(r'[^0-9.]'), '').trim();
      // Eliminar puntos al final
      amountStr = amountStr.replaceAll(RegExp(r'\.+$'), '');
      

      AppLogger.i('PARSER MATCH: Nombre: $name, Moneda: $currency, Monto: $amountStr');
      
      final amount = double.parse(amountStr);

      if (amount <= 0) return const Left(ServerFailure('Monto inválido'));

      if (name.isEmpty) {
        return const Left(ServerFailure('El nombre del emisor está vacío'));
      }

      return Right(PaymentData(
        senderName: name,
        amount: amount,
        currency: currency,
        rawText: raw,
        parsedAt: DateTime.now(),
      ));
    } catch (e) {
      AppLogger.e('PARSER ERROR EXCEPTION: $e');
      return Left(ServerFailure('Error al procesar monto: $e'));
    }
  }
}
