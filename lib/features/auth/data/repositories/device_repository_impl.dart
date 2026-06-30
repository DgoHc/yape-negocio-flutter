import 'package:injectable/injectable.dart';
import '../../domain/entities/device_entity.dart';
import '../../domain/repositories/device_repository.dart';
import '../local_data_source/auth_local_data_source.dart';
import '../models/auth_models.dart';

@Injectable(as: DeviceRepository)
class DeviceRepositoryImpl implements DeviceRepository {
  final AuthLocalDataSource _localDataSource;

  DeviceRepositoryImpl(this._localDataSource);

  @override
  Future<DeviceEntity?> getDeviceByUuid(String uuid) async {
    final deviceModel = await _localDataSource.getDeviceByUuid(uuid);
    if (deviceModel == null) return null;
    return DeviceEntity(
      id: deviceModel.id,
      uuid: deviceModel.uuid,
      alias: deviceModel.alias,
      isApproved: deviceModel.isApproved,
      lastConnectedAt: deviceModel.lastConnectedAt,
    );
  }

  @override
  Future<void> upsertDevice({
    required String uuid,
    required String alias,
    required bool isApproved,
  }) async {
    final deviceModel = DeviceModel(
      uuid: uuid,
      alias: alias,
      isApproved: isApproved,
    );
    await _localDataSource.upsertDevice(deviceModel);
  }
}
