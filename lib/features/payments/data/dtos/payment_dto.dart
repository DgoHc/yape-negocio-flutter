
class PaymentDto {
  final String? id;
  final String senderName;
  final double amount;
  final String currency;
  final String externalId;
  final DateTime createdAt;
  final String? operationNumber;
  final String? rawText;
  final String deviceId;

  PaymentDto({
    this.id,
    required this.senderName,
    required this.amount,
    required this.currency,
    required this.externalId,
    required this.createdAt,
    this.operationNumber,
    this.rawText,
    required this.deviceId,
  });

  Map<String, dynamic> toJson() {
    return {
      'senderName': senderName,
      'amount': amount,
      'currency': currency,
      'externalId': externalId,
      'createdAt': createdAt.toIso8601String(),
      'operationNumber': operationNumber,
      'rawText': rawText,
      'deviceId': deviceId,
    };
  }

  factory PaymentDto.fromJson(Map<String, dynamic> json) {
    return PaymentDto(
      id: json['id'] as String?,
      senderName: json['senderName'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      externalId: json['externalId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      operationNumber: json['operationNumber'] as String?,
      rawText: json['rawText'] as String?,
      deviceId: json['deviceId'] as String? ?? '',
    );
  }
}

