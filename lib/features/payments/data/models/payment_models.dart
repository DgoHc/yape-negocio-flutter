
import 'package:drift/drift.dart' as drift;
import '../../../../core/storage/drift/app_database.dart';

class PaymentModel {
  final int? id;
  final String senderName;
  final double amount;
  final String currency;
  final String externalId;
  final bool isSynced;
  final DateTime createdAt;
  final String? operationNumber;
  final String? rawText;

  PaymentModel({
    this.id,
    required this.senderName,
    required this.amount,
    required this.currency,
    required this.externalId,
    required this.isSynced,
    required this.createdAt,
    this.operationNumber,
    this.rawText,
  });

  factory PaymentModel.fromDb(Payment dbPayment) {
    return PaymentModel(
      id: dbPayment.id,
      senderName: dbPayment.senderName,
      amount: dbPayment.amount,
      currency: dbPayment.currency,
      externalId: dbPayment.externalId,
      isSynced: dbPayment.isSynced,
      createdAt: dbPayment.createdAt,
      operationNumber: dbPayment.operationNumber,
      rawText: dbPayment.rawText,
    );
  }

  PaymentsTableCompanion toDbCompanion() {
    return PaymentsTableCompanion(
      id: id != null ? drift.Value(id!) : const drift.Value.absent(),
      senderName: drift.Value(senderName),
      amount: drift.Value(amount),
      currency: drift.Value(currency),
      externalId: drift.Value(externalId),
      isSynced: drift.Value(isSynced),
      createdAt: drift.Value(createdAt),
      operationNumber: drift.Value(operationNumber),
      rawText: drift.Value(rawText),
    );
  }
}
