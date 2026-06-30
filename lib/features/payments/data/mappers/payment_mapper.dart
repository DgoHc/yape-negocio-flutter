
import '../dtos/payment_dto.dart';
import '../models/payment_models.dart';
import '../../../notifications/domain/entities/payment_data.dart';

class PaymentMapper {
  static PaymentData fromModel(PaymentModel model) {
    return PaymentData(
      senderName: model.senderName,
      amount: model.amount,
      currency: model.currency,
      rawText: '',
      parsedAt: model.createdAt,
    );
  }

  static PaymentData fromDto(PaymentDto dto) {
    return PaymentData(
      senderName: dto.senderName,
      amount: dto.amount,
      currency: dto.currency,
      rawText: '',
      parsedAt: dto.createdAt,
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
    );
  }

  static PaymentDto toDto(PaymentData entity, String externalId) {
    return PaymentDto(
      senderName: entity.senderName,
      amount: entity.amount,
      currency: entity.currency,
      externalId: externalId,
      createdAt: entity.parsedAt,
    );
  }
}
