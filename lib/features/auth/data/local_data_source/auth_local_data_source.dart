
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/storage/drift/app_database.dart';
import '../models/auth_models.dart';

abstract class AuthLocalDataSource {
  Future<UserProfileModel?> getUserProfile();
  Future<List<UserProfileModel>> getAllUserProfiles();
  Future<void> saveUserProfile(UserProfileModel profile);
  Future<void> updateSubscriptionStatus(String id, bool isSubscribed);
  Future<void> deleteUserProfile();
  Future<DeviceModel?> getDeviceByUuid(String uuid);
  Future<void> upsertDevice(DeviceModel device);
}

@Injectable(as: AuthLocalDataSource)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final UserProfileDao _userProfileDao;
  final DeviceDao _deviceDao;

  AuthLocalDataSourceImpl(this._userProfileDao, this._deviceDao);

  @override
  Future<UserProfileModel?> getUserProfile() async {
    final dbProfile = await _userProfileDao.getProfile();
    if (dbProfile == null) return null;
    return UserProfileModel.fromDb(dbProfile);
  }

  @override
  Future<List<UserProfileModel>> getAllUserProfiles() async {
    final dbProfiles = await _userProfileDao.getAllProfiles();
    return dbProfiles.map((p) => UserProfileModel.fromDb(p)).toList();
  }

  @override
  Future<void> saveUserProfile(UserProfileModel profile) async {
    final existing = await _userProfileDao.getProfile();
    final companion = profile.toDbCompanion().copyWith(
      localId: existing != null ? Value(existing.localId) : const Value.absent(),
    );
    await _userProfileDao.upsertProfile(companion);
  }

  @override
  Future<void> updateSubscriptionStatus(String id, bool isSubscribed) async {
    final oldProfile = await _userProfileDao.getProfileById(id);
    if (oldProfile == null) return;

    final companion = UserProfilesTableCompanion(
      localId: Value(oldProfile.localId),
      id: Value(oldProfile.id),
      isSubscribed: Value(isSubscribed),
      subscriptionStartDate: isSubscribed ? Value(DateTime.now()) : const Value.absent(),
      subscriptionEndDate: isSubscribed ? Value(DateTime.now().add(const Duration(days: 30))) : const Value.absent(),
    );
    await _userProfileDao.upsertProfile(companion);
  }

  @override
  Future<void> deleteUserProfile() async {
    await _userProfileDao.deleteProfile();
  }

  @override
  Future<DeviceModel?> getDeviceByUuid(String uuid) async {
    final dbDevice = await _deviceDao.getDeviceByUuid(uuid);
    if (dbDevice == null) return null;
    return DeviceModel.fromDb(dbDevice);
  }

  @override
  Future<void> upsertDevice(DeviceModel device) async {
    await _deviceDao.upsertDevice(device.toDbCompanion());
  }
}
