
import '../dtos/payment_dto.dart';
import '../models/payment_models.dart';
import '../../../notifications/domain/entities/payment_data.dart';

class PaymentMapper {
  static PaymentData fromModel(PaymentModel model) {
    return PaymentData(
      senderName: model.senderName,
      amount: model.amount,
      currency: model.currency,
      rawText: model.rawText ?? '',
      parsedAt: model.createdAt,
      operationNumber: model.operationNumber,
    );
  }

  static PaymentData fromDto(PaymentDto dto) {
    return PaymentData(
      senderName: dto.senderName,
      amount: dto.amount,
      currency: dto.currency,
      rawText: dto.rawText ?? '',
      parsedAt: dto.createdAt,
      operationNumber: dto.operationNumber,
    );
  }

  static PaymentModel toModel(PaymentData entity, String externalId, bool isSynced) {
    return PaymentModel(
      senderName: entity.senderName,
      amount: entity.amount,
      currency: entity.currency,
      externalId: externalId,
      isSynced: isSynced,
      createdAt: entity.parsedAt,
      operationNumber: entity.operationNumber,
      rawText: entity.rawText,
    );
  }

  static PaymentDto toDto(PaymentData entity, String externalId, String deviceId) {
    return PaymentDto(
      senderName: entity.senderName,
      amount: entity.amount,
      currency: entity.currency,
      externalId: externalId,
      createdAt: entity.parsedAt,
      operationNumber: entity.operationNumber,
      rawText: entity.rawText,
      deviceId: deviceId,
    );
  }
}
