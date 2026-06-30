
import 'package:injectable/injectable.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../local_data_source/auth_local_data_source.dart';
import '../mappers/user_profile_mapper.dart';

@Injectable(as: UserProfileRepository)
class UserProfileRepositoryImpl implements UserProfileRepository {
  final AuthLocalDataSource _localDataSource;

  UserProfileRepositoryImpl(this._localDataSource);

  @override
  Future<UserProfile?> getProfile() async {
    final model = await _localDataSource.getUserProfile();
    if (model == null) return null;
    return UserProfileMapper.fromModel(model);
  }

  @override
  Future<List<UserProfile>> getAllProfiles() async {
    final models = await _localDataSource.getAllUserProfiles();
    return models.map((m) => UserProfileMapper.fromModel(m)).toList();
  }

  @override
  Future<UserProfile?> findProfileByEmail(String email) async {
    return null;
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    final model = UserProfileMapper.toModel(profile);
    await _localDataSource.saveUserProfile(model);
  }

  @override
  Future<void> updateSubscriptionStatus(String id, bool isSubscribed) async {
    await _localDataSource.updateSubscriptionStatus(id, isSubscribed);
  }

  @override
  Future<void> deleteProfile() async {
    await _localDataSource.deleteUserProfile();
  }
}
