
import '../../domain/entities/user_profile.dart';
import '../dtos/user_profile_dto.dart';
import '../models/auth_models.dart';

class UserProfileMapper {
  static UserProfile fromDto(UserProfileDto dto) {
    return UserProfile(
      id: dto.id,
      name: dto.name,
      email: dto.email,
      phone: dto.phone,
      uuid: dto.uuid,
      businessType: dto.businessType,
      notificationCode: dto.notificationCode,
      trialStartDate: dto.trialStartDate,
      trialEndDate: dto.trialEndDate,
      subscriptionStartDate: dto.subscriptionStartDate,
      subscriptionEndDate: dto.subscriptionEndDate,
      isSubscribed: dto.isSubscribed,
      subscriptionPlan: dto.subscriptionPlan,
      createdAt: dto.createdAt,
    );
  }

  static UserProfile fromModel(UserProfileModel model) {
    return UserProfile(
      id: model.id,
      name: model.name,
      email: model.email,
      phone: model.phone,
      uuid: model.uuid,
      businessType: model.businessType,
      notificationCode: model.notificationCode,
      trialStartDate: model.trialStartDate,
      trialEndDate: model.trialEndDate,
      subscriptionStartDate: model.subscriptionStartDate,
      subscriptionEndDate: model.subscriptionEndDate,
      isSubscribed: model.isSubscribed,
      subscriptionPlan: model.subscriptionPlan,
      createdAt: model.createdAt,
    );
  }

  static UserProfileDto toDto(UserProfile entity) {
    return UserProfileDto(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      phone: entity.phone,
      uuid: entity.uuid,
      businessType: entity.businessType,
      notificationCode: entity.notificationCode,
      trialStartDate: entity.trialStartDate,
      trialEndDate: entity.trialEndDate,
      subscriptionStartDate: entity.subscriptionStartDate,
      subscriptionEndDate: entity.subscriptionEndDate,
      isSubscribed: entity.isSubscribed,
      subscriptionPlan: entity.subscriptionPlan,
      createdAt: entity.createdAt,
    );
  }

  static UserProfileModel toModel(UserProfile entity) {
    return UserProfileModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      phone: entity.phone,
      uuid: entity.uuid,
      businessType: entity.businessType,
      notificationCode: entity.notificationCode,
      trialStartDate: entity.trialStartDate,
      trialEndDate: entity.trialEndDate,
      subscriptionStartDate: entity.subscriptionStartDate,
      subscriptionEndDate: entity.subscriptionEndDate,
      isSubscribed: entity.isSubscribed,
      subscriptionPlan: entity.subscriptionPlan,
      createdAt: entity.createdAt,
    );
  }
}
