
import 'package:device_info_plus/device_info_plus.dart';
import 'package:injectable/injectable.dart';
import 'dart:io';

class DeviceExtendedInfo {
  final String uuid;
  final String? deviceName;
  final String? brand;
  final String? model;
  final String? androidVersion;

  DeviceExtendedInfo({
    required this.uuid,
    this.deviceName,
    this.brand,
    this.model,
    this.androidVersion,
  });

  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'deviceName': deviceName,
    'brand': brand,
    'model': model,
    'androidVersion': androidVersion,
  };
}

@lazySingleton
class DeviceInfoService {
  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  Future<String?> getDeviceUUID() async {
    final info = await getExtendedInfo();
    return info?.uuid;
  }

  Future<DeviceExtendedInfo?> getExtendedInfo() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        return DeviceExtendedInfo(
          uuid: androidInfo.id,
          deviceName: androidInfo.device,
          brand: androidInfo.brand,
          model: androidInfo.model,
          androidVersion: androidInfo.version.release,
        );
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfoPlugin.iosInfo;
        return DeviceExtendedInfo(
          uuid: iosInfo.identifierForVendor ?? 'ios-unknown',
          deviceName: iosInfo.name,
          brand: 'Apple',
          model: iosInfo.model,
          androidVersion: iosInfo.systemVersion,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
