
enum PaymentProvider {
  culqi,
  mercadoPago,
  yape,
}

class PaymentResult {
  final bool success;
  final String? transactionId;
  final String? errorMessage;
  final PaymentProvider? provider;

  PaymentResult({
    required this.success,
    this.transactionId,
    this.errorMessage,
    this.provider,
  });
}
