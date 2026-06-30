
import '../../domain/entities/notification_link_entities.dart';
import '../dtos/notification_link_dtos.dart';

class NotificationLinkMapper {
  static LinkRequest fromLinkRequestDto(LinkRequestDto dto) {
    return LinkRequest(
      id: dto.id,
      senderId: dto.senderId,
      receiverId: dto.receiverId,
      status: dto.status,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
      sender: dto.sender,
      receiver: dto.receiver,
    );
  }

  static UserLink fromUserLinkDto(UserLinkDto dto) {
    return UserLink(
      id: dto.id,
      sourceId: dto.sourceId,
      targetId: dto.targetId,
      alias: dto.alias,
      status: dto.status,
      linkedAt: dto.linkedAt,
      updatedAt: dto.updatedAt,
      source: dto.source,
      target: dto.target,
    );
  }
}
