import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/app_logger.dart';
import 'package:injectable/injectable.dart';
import '../entities/payment_data.dart';

@lazySingleton
class PaymentParser {
  /// Palabras clave que indican que es SOLO una notificación de seguridad (Blacklist)
  static final List<String> _securityKeywords = [
    "código de seguridad",
    "clave de acceso",
    "iniciaste sesión",
    "tu clave es",
    "seguridad es",
  ];

  /// Lista de regex para diferentes formatos de Yape (Personal, Negocios, etc.)
  static final List<RegExp> _incomingPaymentRegexes = [
    // Formato Negocios: ¡Te yapearon! Juan Perez - S/ 10.00
    RegExp(r"¡?Te\s+yapearon!?\s+(.+?)\s*[-–]\s*(?:S/|PEN|S\./)\s*([\d,.]+)", caseSensitive: false),
    // Formato 1: [Nombre] te envió un pago por S/ [Monto]
    RegExp(r"(.+?)\s+te\s+envió\s+un\s+pago\s+por\s+(S/|PEN|S\./)\s*([\d,.]+)", caseSensitive: false),
    // Formato 2: ¡Recibiste un Yape! [Nombre] te envió (S/|PEN) [Monto]
    RegExp(r"¡?Recibiste\s+un\s+Yape!?\s+(.+?)\s+te\s+envió\s+(S/|PEN|S\./)\s*([\d,.]+)", caseSensitive: false),
    // Formato 3: [Nombre] te yapeó S/ [Monto]
    RegExp(r"(.+?)\s+te\s+yapeó\s+(S/|PEN|S\./)\s*([\d,.]+)", caseSensitive: false),
    // Formato 4: Nuevo pago de [Nombre] por (S/|PEN) [Monto]
    RegExp(r"Nuevo\s+pago\s+de\s+(.+?)\s+por\s+(S/|PEN|S\./)\s*([\d,.]+)", caseSensitive: false),
    // Formato 5: Has recibido (S/|PEN) [Monto] de [Nombre]
    RegExp(r"Has\s+recibido\s+(S/|PEN|S\./)\s*([\d,.]+)\s+de\s+(.+)", caseSensitive: false),
    // Formato Directo: [Nombre] - S/ [Monto]
    RegExp(r"^(.+?)\s*[-–]\s*(?:S/|PEN|S\./)\s*([\d,.]+)$", caseSensitive: false),
  ];

  static Either<Failure, PaymentData> parse(String raw) {
    AppLogger.d('PARSER INPUT: "$raw"');
    
    if (raw.isEmpty) {
      return const Left(ServerFailure('Texto vacío'));
    }

    // Normalización del texto
    final cleanRaw = raw.replaceAll(RegExp(r'[\r\n|]+'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
    
    String? senderName;
    double? amount;
    String? currency = "S/";

    // 1. Intentar con las regex de pagos PRIMERO
    for (final regex in _incomingPaymentRegexes) {
      final match = regex.firstMatch(cleanRaw);
      if (match != null) {
        if (regex.pattern.contains('Has\\\\s+recibido')) {
          currency = match.group(1)?.trim() ?? "S/";
          final amountStr = match.group(2)?.replaceAll(RegExp(r'[^0-9.]'), '').trim() ?? "0";
          amount = double.tryParse(amountStr);
          senderName = match.group(3)?.trim();
        } else {
          senderName = match.group(1)?.trim();
          if (match.groupCount >= 3) {
            currency = match.group(2)?.trim() ?? "S/";
            final amountStr = match.group(3)?.replaceAll(RegExp(r'[^0-9.]'), '').trim() ?? "0";
            amount = double.tryParse(amountStr);
          } else {
            final amountStr = match.group(2)?.replaceAll(RegExp(r'[^0-9.]'), '').trim() ?? "0";
            amount = double.tryParse(amountStr);
          }
        }
        if (senderName != null && amount != null && amount > 0) break;
      }
    }

    // 2. Si no es un pago, verificar si es una notificación de seguridad pura
    if (senderName == null || amount == null || amount <= 0) {
      final lowerRaw = raw.toLowerCase();
      for (final word in _securityKeywords) {
        if (lowerRaw.contains(word)) {
          return const Left(ServerFailure('Seguridad ignorada'));
        }
      }
    }

    if (senderName == null || amount == null || amount <= 0) {
      return const Left(ServerFailure('Formato no reconocido'));
    }

    // LIMPIEZA AGRESIVA DEL NOMBRE:
    // 1. Quitar prefijos comunes de Yape
    senderName = senderName
        .replaceAll(RegExp(r"^(?:Yape:?\s*|¡?Te\s+yapearon!?\s*|¡?Recibiste\s+un\s+Yape!?\s*)", caseSensitive: false), "")
        .trim();
    
    // 2. QUITAR ASTERISCOS (*) - Esto evita que el TTS los lea
    senderName = senderName.replaceAll('*', '');
    
    // 3. Quitar puntos suspensivos o caracteres raros al final
    senderName = senderName.replaceAll(RegExp(r'[.|*#\-_]+$'), '').trim();

    AppLogger.i('PARSER SUCCESS: $senderName | $amount');

    return Right(PaymentData(
      senderName: senderName,
      amount: amount,
      currency: currency ?? "S/",
      rawText: raw,
      parsedAt: DateTime.now(),
    ));
  }
}
