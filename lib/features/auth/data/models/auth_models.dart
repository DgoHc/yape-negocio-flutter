
import 'package:drift/drift.dart' as drift;
import '../../../../core/storage/drift/app_database.dart';

class UserProfileModel {
  final int? localId;
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

  UserProfileModel({
    this.localId,
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

  factory UserProfileModel.fromDb(dynamic dbProfile) {
    // Usamos dynamic para evitar errores antes de la regeneración de Drift
    String? plan;
    try {
      plan = (dbProfile as dynamic).subscriptionPlan;
    } catch (_) {
      plan = null;
    }

    return UserProfileModel(
      localId: dbProfile.localId,
      id: dbProfile.id,
      name: dbProfile.name,
      email: dbProfile.email,
      phone: dbProfile.phone,
      uuid: dbProfile.uuid,
      businessType: dbProfile.businessType,
      notificationCode: dbProfile.notificationCode,
      trialStartDate: dbProfile.trialStartDate,
      trialEndDate: dbProfile.trialEndDate,
      subscriptionStartDate: dbProfile.subscriptionStartDate,
      subscriptionEndDate: dbProfile.subscriptionEndDate,
      isSubscribed: dbProfile.isSubscribed,
      subscriptionPlan: plan,
      createdAt: dbProfile.createdAt,
    );
  }

  UserProfilesTableCompanion toDbCompanion() {
    return UserProfilesTableCompanion(
      localId: localId != null ? drift.Value(localId!) : const drift.Value.absent(),
      id: id != null ? drift.Value(id!) : const drift.Value.absent(),
      name: drift.Value(name),
      email: email != null ? drift.Value(email!) : const drift.Value.absent(),
      phone: phone != null ? drift.Value(phone!) : const drift.Value.absent(),
      uuid: uuid != null ? drift.Value(uuid!) : const drift.Value.absent(),
      businessType: businessType != null
          ? drift.Value(businessType!)
          : const drift.Value.absent(),
      notificationCode: notificationCode != null
          ? drift.Value(notificationCode!)
          : const drift.Value.absent(),
      trialStartDate: trialStartDate != null
          ? drift.Value(trialStartDate!)
          : const drift.Value.absent(),
      trialEndDate: trialEndDate != null
          ? drift.Value(trialEndDate!)
          : const drift.Value.absent(),
      subscriptionStartDate: subscriptionStartDate != null
          ? drift.Value(subscriptionStartDate!)
          : const drift.Value.absent(),
      subscriptionEndDate: subscriptionEndDate != null
          ? drift.Value(subscriptionEndDate!)
          : const drift.Value.absent(),
      isSubscribed: drift.Value(isSubscribed),
      // Comentado temporalmente hasta que se ejecute build_runner
      // subscriptionPlan: subscriptionPlan != null ? drift.Value(subscriptionPlan!) : const drift.Value.absent(),
      createdAt: drift.Value(createdAt),
    );
  }
}

class DeviceModel {
  final int? id;
  final String uuid;
  final String alias;
  final bool isApproved;
  final DateTime? lastConnectedAt;

  DeviceModel({
    this.id,
    required this.uuid,
    required this.alias,
    required this.isApproved,
    this.lastConnectedAt,
  });

  factory DeviceModel.fromDb(Device dbDevice) {
    return DeviceModel(
      id: dbDevice.id,
      uuid: dbDevice.uuid,
      alias: dbDevice.alias,
      isApproved: dbDevice.isApproved,
      lastConnectedAt: dbDevice.lastConnectedAt,
    );
  }

  DevicesTableCompanion toDbCompanion() {
    return DevicesTableCompanion(
      id: id != null ? drift.Value(id!) : const drift.Value.absent(),
      uuid: drift.Value(uuid),
      alias: drift.Value(alias),
      isApproved: drift.Value(isApproved),
      lastConnectedAt: lastConnectedAt != null
          ? drift.Value(lastConnectedAt!)
          : const drift.Value.absent(),
    );
  }
}
