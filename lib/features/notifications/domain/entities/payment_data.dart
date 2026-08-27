import 'package:equatable/equatable.dart';

class PaymentData extends Equatable {
  final String senderName;
  final double amount;
  final String currency;
  final String rawText;
  final DateTime parsedAt;
  final String? operationNumber;
  final String? time;

  const PaymentData({
    required this.senderName,
    required this.amount,
    required this.currency,
    required this.rawText,
    required this.parsedAt,
    this.operationNumber,
    this.time,
  });

  @override
  List<Object?> get props => [
        senderName,
        amount,
        currency,
        rawText,
        parsedAt,
        operationNumber,
        time,
      ];
}
