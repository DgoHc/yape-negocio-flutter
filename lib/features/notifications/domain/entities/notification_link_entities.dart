
class LinkRequest {
  final String id;
  final String senderId;
  final String receiverId;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? sender;
  final Map<String, dynamic>? receiver;

  LinkRequest({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.sender,
    this.receiver,
  });
}

class UserLink {
  final String id;
  final String sourceId;
  final String targetId;
  final String? alias;
  final String status;
  final DateTime linkedAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? source;
  final Map<String, dynamic>? target;

  UserLink({
    required this.id,
    required this.sourceId,
    required this.targetId,
    this.alias,
    required this.status,
    required this.linkedAt,
    required this.updatedAt,
    this.source,
    this.target,
  });
}
