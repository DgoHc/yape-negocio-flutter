import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/app_logger.dart';
import 'package:injectable/injectable.dart';
import '../entities/payment_data.dart';

@lazySingleton
class PaymentParser {
  static final List<String> _promoKeywords = [
    "promoción", "promocion", "descuento", "cupón", "cupon", "oferta", "sorteo",
    "premio", "gana", "ganaste", "cashback", "beneficio", "crédito", "credito",
    "regalo", "aprovecha", "descubre", "recompensa", "recarga", "sortea",
    "invita y gana", "yape te regala", "paga y gana"
  ];

  static final List<String> _securityKeywords = [
    "código de seguridad para iniciar",
    "clave de acceso",
    "iniciaste sesión",
    "tu clave secreta es",
    "intento de inicio de sesión",
  ];

  static final List<String> _outgoingKeywords = [
    "enviaste un yape",
    "yapeaste s/",
    "yapeaste a ",
    "le enviaste",
    "transferencia realizada con éxito",
    "has enviado s/",
    "pago realizado a ",
    "pago exitoso a ",
  ];

  static final List<RegExp> _incomingPaymentRegexes = [
    // FORMATOS YAPE & GENERALES
    RegExp(r"Confirmaci[óo]n\s+de\s+Pago\s+(?:Yape!?\s*)?(.+?)\s*[-–]?\s*(?:S/|PEN|S\./)\s*(\d+(?:[.,]\d+)?)", caseSensitive: false),
    RegExp(r"Te\s+yapeó\s+(S/|PEN|S\./)\s*(\d+(?:[.,]\d+)?)\s+(.+)", caseSensitive: false),
    RegExp(r"(.+?)\s+te\s+yapeó\s+(S/|PEN|S\./)\s*(\d+(?:[.,]\d+)?)", caseSensitive: false),
    RegExp(r"¡?Te\s+yapearon!?\s+(.+?)\s*[-–]\s*(?:S/|PEN|S\./)\s*(\d+(?:[.,]\d+)?)", caseSensitive: false),
    RegExp(r"(?:Confirmaci[óo]n\s+)?(.+?)\s+te\s+envi[óo]\s+(?:un\s+pago\s+)?(?:por|de)\s*(?:S/|PEN|S\./)?\s*(\d+(?:[.,]\d+)?)", caseSensitive: false),
    RegExp(r"(?:Confirmaci[óo]n\s+)?(.+?)\s+te\s+envi[óo]\s+(?:S/|PEN|S\./)\s*(\d+(?:[.,]\d+)?)", caseSensitive: false),
    RegExp(r"¡?Recibiste\s+un\s+Yape!?\s+(.+?)\s+te\s+envió\s+(S/|PEN|S\./)\s*(\d+(?:[.,]\d+)?)", caseSensitive: false),
    RegExp(r"Nuevo\s+pago\s+de\s+(.+?)\s+por\s+(S/|PEN|S\./)\s*(\d+(?:[.,]\d+)?)", caseSensitive: false),
    RegExp(r"Has\s+recibido\s+(S/|PEN|S\./)\s*(\d+(?:[.,]\d+)?)\s+de\s+(.+)", caseSensitive: false),
    RegExp(r"Recibiste\s+(S/|PEN|S\./)\s*(\d+(?:[.,]\d+)?)\s+de\s+(.+)", caseSensitive: false),

    // FORMATOS MI BANCO & CAJAS
    RegExp(r"Mi\s*Banco:?\s*(?:Confirmaci[óo]n\s+)?(.+?)\s+te\s+envi[óo]\s+(?:un\s+pago\s+)?(?:por|de)?\s*(?:S/|PEN|S\./)?\s*(\d+(?:[.,]\d+)?)", caseSensitive: false),

    // FORMATOS PLIN
    RegExp(r"(?:Recibiste\s+un\s+Plin!?)\s+(.+?)\s+te\s+envió\s+(?:S/|PEN|S\./)\s*(\d+(?:[.,]\d+)?)", caseSensitive: false),
    RegExp(r"Plin:?\s+Has\s+recibido\s+(?:S/|PEN|S\./)\s*(\d+(?:[.,]\d+)?)\s+de\s+(.+)", caseSensitive: false),
    RegExp(r"(.+?)\s+te\s+envió\s+un\s+Plin\s+por\s+(?:S/|PEN|S\./)\s*(\d+(?:[.,]\d+)?)", caseSensitive: false),
    RegExp(r"Plin\s+de\s+(.+?)\s+por\s+(?:S/|PEN|S\./)\s*(\d+(?:[.,]\d+)?)", caseSensitive: false),
  ];

  static Either<Failure, PaymentData> parse(String raw) {
    AppLogger.d('PARSER INPUT: "$raw"');
    
    if (raw.trim().isEmpty) {
      return const Left(ServerFailure('Texto vacío'));
    }

    final lowerRaw = raw.toLowerCase();

    // 0. FILTRAR NOTIFICACIONES PROMOCIONALES / PUBLICITARIAS DE YAPE/PLIN
    final isStrictPaymentHeader = lowerRaw.contains("confirmación de pago") ||
        lowerRaw.contains("confirmacion de pago") ||
        lowerRaw.contains("te yapeó") ||
        lowerRaw.contains("te yapeo") ||
        lowerRaw.contains("te envió") ||
        lowerRaw.contains("te envio");

    if (!isStrictPaymentHeader) {
      for (final promoWord in _promoKeywords) {
        if (lowerRaw.contains(promoWord)) {
          AppLogger.w('PaymentParser: Ignorando notificación promocional: "$raw"');
          return const Left(ServerFailure('Promoción ignorada'));
        }
      }
    }

    // 1. FILTRAR NOTIFICACIONES DE PAGOS SALIENTES
    for (final word in _outgoingKeywords) {
      if (lowerRaw.contains(word)) {
        AppLogger.w('PaymentParser: Ignorando notificación de pago saliente: "$raw"');
        return const Left(ServerFailure('Pago saliente ignorado'));
      }
    }

    // 2. LIMPIAR SUFIJO DE SEGURIDAD DE YAPE ("El cód. de seguridad es: XXX")
    var cleanRaw = raw
        .replaceAll(RegExp(r"\.\s*El\s+c[óo]d(?:\.|igo)?\s+de\s+seguridad\s+es:?.*$", caseSensitive: false), "")
        .replaceAll(RegExp(r'[\r\n|]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    String? senderName;
    double? amount;
    String? currency = "S/";

    // 3. INTENTAR EXTRAER EL PAGO CON REGLAS ESTRUCTURADAS
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

    // 4. FALLBACK EXIGES PALABRAS CLAVE Y SÍMBOLO MONEDA (RESTRINGIDO)
    if (senderName == null || amount == null || amount <= 0) {
      final amountMatch = RegExp(r"(?:S/|PEN|S\./)\s*(\d+(?:[.,]\d+)?)", caseSensitive: false).firstMatch(cleanRaw);
      if (amountMatch != null) {
        final parsedAmount = double.tryParse(amountMatch.group(1)?.replaceAll(',', '.') ?? '');
        final hasPaymentKeyword = ["yapeó", "yapeo", "te envió", "te envio", "confirmación de pago", "confirmacion de pago", "recibiste un plin", "recibiste un yape"]
            .any((verb) => lowerRaw.contains(verb));
            
        if (parsedAmount != null && parsedAmount > 0 && hasPaymentKeyword) {
          amount = parsedAmount;
          var rawName = cleanRaw.replaceAll(amountMatch.group(0)!, '').trim();
          senderName = cleanSenderName(rawName);
        }
      }
    }

    // 5. SI NO COINCIDIÓ NINGUNA REGLA DE PAGO, COMPROBAR SI ES SOLO UN MENSAJE DE SEGURIDAD
    if (senderName == null || amount == null || amount <= 0) {
      for (final word in _securityKeywords) {
        if (lowerRaw.contains(word)) {
          return const Left(ServerFailure('Seguridad ignorada'));
        }
      }
      return const Left(ServerFailure('Formato no reconocido'));
    }

    // 6. LIMPIEZA AGRESIVA DEL NOMBRE DE REMITENTE
    senderName = cleanSenderName(senderName);

    AppLogger.i('PARSER SUCCESS: $senderName | $amount');

    return Right(PaymentData(
      senderName: senderName,
      amount: amount,
      currency: currency ?? "S/",
      rawText: raw,
      parsedAt: DateTime.now(),
    ));
  }

  static String cleanSenderName(String name) {
    var cleaned = name;

    cleaned = cleaned
        .replaceAll(RegExp(r"\s+te\s+(?:envi[óo]|yape[óo]).*$", caseSensitive: false), "")
        .replaceAll(RegExp(r"\s+(?:envi[óo]|yape[óo])\s+un\s+pago.*$", caseSensitive: false), "")
        .replaceAll(RegExp(r"\s+(?:por|de)\s*(?:S/|PEN|S\./)?\s*\d+.*$", caseSensitive: false), "")
        .replaceAll(RegExp(r"\s+El\s+c[óo]d.*$", caseSensitive: false), "");

    cleaned = cleaned.replaceAll(RegExp(r'[*＊#_~^•·¡!]+'), ' ');

    cleaned = cleaned.replaceAll(
      RegExp(r"^(?:Confirmaci[óo]n(?:\s+de)?(?:\s+Pago)?(?:\s+Yape!?)?|Mi\s*Banco:?|Yape:?|Plin:?|¡?Te\s+yapearon!?|¡?Recibiste\s+un\s+(?:Yape|Plin)!?)\s*", caseSensitive: false),
      "",
    );

    cleaned = cleaned
        .replaceAll(RegExp(r"\b(?:Confirmaci[óo]n|de|Pago|Yape|Plin|Mi|Banco|Recibiste|un|te|envi[óo]|yape[óo]|por|soles|PEN|S/|Tag\d*)\b", caseSensitive: false), " ");

    cleaned = cleaned.replaceAll(RegExp(r"^[^a-zA-ZáéíóúÁÉÍÓÚñÑ0-9]+"), "");
    cleaned = cleaned.replaceAll(RegExp(r"[^a-zA-ZáéíóúÁÉÍÓÚñÑ0-9]+$"), "");

    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();

    return cleaned.isEmpty ? "Cliente" : cleaned;
  }
}
