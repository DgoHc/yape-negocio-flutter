import '../entities/user_profile.dart';

abstract class UserProfileRepository {
  Future<UserProfile?> getProfile();
  Future<List<UserProfile>> getAllProfiles();
  Future<UserProfile?> findProfileByEmail(String email);
  Future<void> saveProfile(UserProfile profile);
  Future<void> updateSubscriptionStatus(String id, bool isSubscribed);
  Future<void> deleteProfile();
}
