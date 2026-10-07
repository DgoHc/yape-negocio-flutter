import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/app_logger.dart';
import 'package:injectable/injectable.dart';
import '../entities/payment_data.dart';

@lazySingleton
class PaymentParser {
  static final List<String> _securityKeywords = [
    "código de seguridad",
    "clave de acceso",
    "iniciaste sesión",
    "tu clave es",
    "seguridad es",
    "intento de inicio",
  ];

  static final List<RegExp> _incomingPaymentRegexes = [
    RegExp(r"Confirmaci[óo]n\s+de\s+Pago\s+(?:Yape!?\s*)?(.+?)\s*[-–]?\s*(?:S/|PEN|S\./)\s*(\d+(?:[.,]\d+)?)", caseSensitive: false),
    RegExp(r"Te\s+yapeó\s+(S/|PEN|S\./)\s*(\d+(?:[.,]\d+)?)\s+(.+)", caseSensitive: false),
    RegExp(r"(.+?)\s+te\s+yapeó\s+(S/|PEN|S\./)\s*(\d+(?:[.,]\d+)?)", caseSensitive: false),
    RegExp(r"¡?Te\s+yapearon!?\s+(.+?)\s*[-–]\s*(?:S/|PEN|S\./)\s*(\d+(?:[.,]\d+)?)", caseSensitive: false),
    RegExp(r"(.+?)\s+te\s+envió\s+un\s+pago\s+por\s+(S/|PEN|S\./)\s*(\d+(?:[.,]\d+)?)", caseSensitive: false),
    RegExp(r"¡?Recibiste\s+un\s+Yape!?\s+(.+?)\s+te\s+envió\s+(S/|PEN|S\./)\s*(\d+(?:[.,]\d+)?)", caseSensitive: false),
    RegExp(r"Nuevo\s+pago\s+de\s+(.+?)\s+por\s+(S/|PEN|S\./)\s*(\d+(?:[.,]\d+)?)", caseSensitive: false),
    RegExp(r"Has\s+recibido\s+(S/|PEN|S\./)\s*(\d+(?:[.,]\d+)?)\s+de\s+(.+)", caseSensitive: false),
    RegExp(r"Recibiste\s+(S/|PEN|S\./)\s*(\d+(?:[.,]\d+)?)\s+de\s+(.+)", caseSensitive: false),
    RegExp(r"^(.+?)\s*[-–]\s*(?:S/|PEN|S\./)\s*(\d+(?:[.,]\d+)?)$", caseSensitive: false),

    // FORMATOS PLIN
    RegExp(r"(?:Recibiste\s+un\s+Plin!?)\s+(.+?)\s+te\s+envió\s+(?:S/|PEN|S\./)\s*(\d+(?:[.,]\d+)?)", caseSensitive: false),
    RegExp(r"Plin:?\s+Has\s+recibido\s+(?:S/|PEN|S\./)\s*(\d+(?:[.,]\d+)?)\s+de\s+(.+)", caseSensitive: false),
    RegExp(r"(.+?)\s+te\s+envió\s+un\s+Plin\s+por\s+(?:S/|PEN|S\./)\s*(\d+(?:[.,]\d+)?)", caseSensitive: false),
    RegExp(r"Plin\s+de\s+(.+?)\s+por\s+(?:S/|PEN|S\./)\s*(\d+(?:[.,]\d+)?)", caseSensitive: false),
  ];

  static Either<Failure, PaymentData> parse(String raw) {
    AppLogger.d('PARSER INPUT: "$raw"');
    
    if (raw.isEmpty) {
      return const Left(ServerFailure('Texto vacío'));
    }

    final cleanRaw = raw.replaceAll(RegExp(r'[\r\n|]+'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
    
    String? senderName;
    double? amount;
    String? currency = "S/";

    for (final regex in _incomingPaymentRegexes) {
      final match = regex.firstMatch(cleanRaw);
      if (match != null) {
        if (cleanRaw.toLowerCase().startsWith("te yapeó")) {
          currency = match.group(1)?.trim() ?? "S/";
          final amountStr = match.group(2)?.replaceAll(',', '.').trim() ?? "0";
          amount = double.tryParse(amountStr);
          senderName = match.group(3)?.trim();
        } else if (regex.pattern.contains('de\\\\s+\\(.+\\)') || regex.pattern.contains('de\\\\s+\\.\\+')) {
           if (regex.pattern.contains('Plin')) {
             final amountStr = match.group(1)?.replaceAll(',', '.').trim() ?? "0";
             amount = double.tryParse(amountStr);
             senderName = match.group(2)?.trim();
           } else {
             currency = match.group(1)?.trim() ?? "S/";
             final amountStr = match.group(2)?.replaceAll(',', '.').trim() ?? "0";
             amount = double.tryParse(amountStr);
             senderName = match.group(3)?.trim();
           }
        } else {
          senderName = match.group(1)?.trim();
          if (match.groupCount >= 2) {
            final amountStr = (match.groupCount >= 3) 
                ? match.group(3)?.replaceAll(',', '.').trim() ?? "0"
                : match.group(2)?.replaceAll(',', '.').trim() ?? "0";
            amount = double.tryParse(amountStr);
            if (match.groupCount >= 3) {
              currency = match.group(2)?.trim() ?? "S/";
            }
          }
        }
        if (senderName != null && amount != null && amount > 0) break;
      }
    }

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

    // LIMPIEZA AGRESIVA DEL NOMBRE DE REMITENTE Y ELIMINACIÓN DE ASTERISCOS
    senderName = _cleanSenderName(senderName);

    AppLogger.i('PARSER SUCCESS: $senderName | $amount');

    return Right(PaymentData(
      senderName: senderName,
      amount: amount,
      currency: currency ?? "S/",
      rawText: raw,
      parsedAt: DateTime.now(),
    ));
  }

  static String _cleanSenderName(String name) {
    var cleaned = name;

    // 1. Quitar asteriscos y numerales para evitar que TTS diga "asterisco"
    cleaned = cleaned.replaceAll('*', '').replaceAll('#', '');

    // 2. Quitar prefijos comunes de Yape/Plin y frases de sistema
    cleaned = cleaned.replaceAll(
      RegExp(r"^(?:Confirmaci[óo]n(?:\s+de)?(?:\s+Pago)?(?:\s+Yape!?)?|Yape:?|Plin:?|¡?Te\s+yapearon!?|¡?Recibiste\s+un\s+(?:Yape|Plin)!?)\s*", caseSensitive: false),
      "",
    );

    // 3. Limpieza adicional de "Confirmación de Pago" o "Yape!" si persisten
    cleaned = cleaned
        .replaceAll(RegExp(r"^Confirmaci[óo]n\s+de\s+(?:Pago\s+)?(?:Yape!?)?\s*", caseSensitive: false), "")
        .replaceAll(RegExp(r"^Yape!|\bYape!\b", caseSensitive: false), "");

    // 4. Quitar caracteres especiales iniciales/finales
    cleaned = cleaned.replaceAll(RegExp(r"^[¡!*#\-_]+\s*"), "");
    cleaned = cleaned.replaceAll(RegExp(r"[.|*#\-_]+$"), "").trim();

    return cleaned.isEmpty ? "Cliente Yape" : cleaned;
  }
}
