
class NotificationCodeDto {
  final String code;

  NotificationCodeDto({required this.code});

  factory NotificationCodeDto.fromJson(Map<String, dynamic> json) {
    return NotificationCodeDto(code: json['notificationCode'] as String? ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'notificationCode': code};
  }
}

class LinkRequestDto {
  final String id;
  final String senderId;
  final String receiverId;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? sender;
  final Map<String, dynamic>? receiver;

  LinkRequestDto({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.sender,
    this.receiver,
  });

  factory LinkRequestDto.fromJson(Map<String, dynamic> json) {
    return LinkRequestDto(
      id: json['id'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      receiverId: json['receiverId'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
      sender: json['sender'] != null ? Map<String, dynamic>.from(json['sender']) : null,
      receiver: json['receiver'] != null ? Map<String, dynamic>.from(json['receiver']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (sender != null) 'sender': sender,
      if (receiver != null) 'receiver': receiver,
    };
  }
}

class UserLinkDto {
  final String id;
  final String sourceId;
  final String targetId;
  final String? alias;
  final String status;
  final DateTime linkedAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? source;
  final Map<String, dynamic>? target;

  UserLinkDto({
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

  factory UserLinkDto.fromJson(Map<String, dynamic> json) {
    return UserLinkDto(
      id: json['id'] as String? ?? '',
      sourceId: json['sourceId'] as String? ?? '',
      targetId: json['targetId'] as String? ?? '',
      alias: json['alias'] as String?,
      status: json['status'] as String? ?? 'active',
      linkedAt: DateTime.tryParse(json['linkedAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
      source: json['source'] != null ? Map<String, dynamic>.from(json['source']) : null,
      target: json['target'] != null ? Map<String, dynamic>.from(json['target']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sourceId': sourceId,
      'targetId': targetId,
      'alias': alias,
      'status': status,
      'linkedAt': linkedAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (source != null) 'source': source,
      if (target != null) 'target': target,
    };
  }
}
