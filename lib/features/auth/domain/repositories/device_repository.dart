import '../entities/device_entity.dart';

abstract class DeviceRepository {
  Future<DeviceEntity?> getDeviceByUuid(String uuid);
  Future<void> upsertDevice({
    required String uuid,
    required String alias,
    required bool isApproved,
  });
}
