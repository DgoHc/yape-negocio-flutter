
class UserProfileDto {
  final String? id;
  final String name;
  final String? email;
  final String? phone;
  final String? uuid;
  final String? businessType;
  final String? notificationCode;
  final DateTime? trialStartDate;
  final DateTime? trialEndDate;
  final DateTime? subscriptionStartDate;
  final DateTime? subscriptionEndDate;
  final bool isSubscribed;
  final String? subscriptionPlan;
  final DateTime createdAt;

  UserProfileDto({
    this.id,
    required this.name,
    this.email,
    this.phone,
    this.uuid,
    this.businessType,
    this.notificationCode,
    this.trialStartDate,
    this.trialEndDate,
    this.subscriptionStartDate,
    this.subscriptionEndDate,
    required this.isSubscribed,
    this.subscriptionPlan,
    required this.createdAt,
  });

  factory UserProfileDto.fromJson(Map<String, dynamic> json) {
    return UserProfileDto(
      id: json['id']?.toString(),
      name: json['name']?.toString() ?? 'Usuario',
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      uuid: json['uuid']?.toString(),
      businessType: json['businessType']?.toString(),
      notificationCode: json['notificationCode']?.toString(),
      trialStartDate: _parseDate(json['trialStartDate']),
      trialEndDate: _parseDate(json['trialEndDate']),
      subscriptionStartDate: _parseDate(json['subscriptionStartDate']),
      subscriptionEndDate: _parseDate(json['subscriptionEndDate']),
      isSubscribed: json['isSubscribed'] is bool 
          ? json['isSubscribed'] as bool 
          : (json['isSubscribed']?.toString() == 'true'),
      subscriptionPlan: json['subscriptionPlan']?.toString(),
      createdAt: _parseDate(json['createdAt']) ?? DateTime.now(),
    );
  }

  static DateTime? _parseDate(dynamic date) {
    if (date == null) return null;
    try {
      return DateTime.parse(date.toString());
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'uuid': uuid,
      'businessType': businessType,
      'notificationCode': notificationCode,
      'trialStartDate': trialStartDate?.toIso8601String(),
      'trialEndDate': trialEndDate?.toIso8601String(),
      'subscriptionStartDate': subscriptionStartDate?.toIso8601String(),
      'subscriptionEndDate': subscriptionEndDate?.toIso8601String(),
      'isSubscribed': isSubscribed,
      'subscriptionPlan': subscriptionPlan,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
