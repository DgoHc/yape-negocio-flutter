/// Entidad de dominio para el perfil de usuario.
///
/// Contiene información personal, estado de suscripción y prueba gratuita.
class UserProfile {
  final String? id;
  final String name;
  final String? email;
  final String? phone;
  final String? uuid;
  final String? businessType; // Rubro: transporte, librería, etc.
  final String? notificationCode; // Código único para vinculación de notificaciones
  final DateTime? trialStartDate;
  final DateTime? trialEndDate;
  final DateTime? subscriptionStartDate;
  final DateTime? subscriptionEndDate;
  final bool isSubscribed;
  final String? subscriptionPlan; // 'basic' o 'premium'
  final DateTime createdAt;

  UserProfile({
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

  /// Indica si el usuario tiene acceso (prueba activa o suscripción válida.
  bool get hasAccess {
    final now = DateTime.now();
    if (isSubscribed) {
      if (subscriptionEndDate != null) {
        return now.isBefore(subscriptionEndDate!);
      }
      return true;
    }
    if (trialEndDate != null) {
      return now.isBefore(trialEndDate!);
    }
    return false;
  }

  /// Indica si la prueba gratuita está activa.
  bool get isTrialActive {
    final now = DateTime.now();
    if (trialEndDate != null) {
      return now.isBefore(trialEndDate!);
    }
    return false;
  }

  /// Crea un perfil con prueba gratuita activa.
  factory UserProfile.createTrial({
    required String name,
    String? email,
    String? phone,
    String? uuid,
    String? businessType,
    String? notificationCode,
  }) {
    final now = DateTime.now();
    return UserProfile(
      name: name,
      email: email,
      phone: phone,
      uuid: uuid,
      businessType: businessType,
      notificationCode: notificationCode,
      trialStartDate: now,
      trialEndDate: now.add(const Duration(days: 14)),
      isSubscribed: false,
      createdAt: now,
    );
  }

  /// Crea un perfil con suscripción activa.
  factory UserProfile.createSubscription({
    required String name,
    String? email,
    String? phone,
    String? uuid,
    String? businessType,
    String? notificationCode,
    String? subscriptionPlan,
  }) {
    final now = DateTime.now();
    return UserProfile(
      name: name,
      email: email,
      phone: phone,
      uuid: uuid,
      businessType: businessType,
      notificationCode: notificationCode,
      subscriptionStartDate: now,
      subscriptionEndDate: now.add(const Duration(days: 30)),
      isSubscribed: true,
      subscriptionPlan: subscriptionPlan,
      createdAt: now,
    );
  }

  /// Crea una copia del perfil con los campos actualizados.
  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? uuid,
    String? businessType,
    String? notificationCode,
    DateTime? trialStartDate,
    DateTime? trialEndDate,
    DateTime? subscriptionStartDate,
    DateTime? subscriptionEndDate,
    bool? isSubscribed,
    String? subscriptionPlan,
    DateTime? createdAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      uuid: uuid ?? this.uuid,
      businessType: businessType ?? this.businessType,
      notificationCode: notificationCode ?? this.notificationCode,
      trialStartDate: trialStartDate ?? this.trialStartDate,
      trialEndDate: trialEndDate ?? this.trialEndDate,
      subscriptionStartDate: subscriptionStartDate ?? this.subscriptionStartDate,
      subscriptionEndDate: subscriptionEndDate ?? this.subscriptionEndDate,
      isSubscribed: isSubscribed ?? this.isSubscribed,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
