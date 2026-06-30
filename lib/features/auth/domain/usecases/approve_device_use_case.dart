
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../../core/services/device_info_service.dart';

class ApproveDeviceParams {
  final String deviceId;
  final String? alias;
  final Map<String, dynamic>? extendedInfo;

  ApproveDeviceParams({
    required this.deviceId, 
    this.alias,
    this.extendedInfo,
  });
}

@injectable
class ApproveDeviceUseCase implements UseCase<void, ApproveDeviceParams> {
  final AuthRepository _authRepository;
  final DeviceInfoService _deviceInfoService;

  ApproveDeviceUseCase(this._authRepository, this._deviceInfoService);

  @override
  Future<Either<Failure, void>> call(ApproveDeviceParams params) async {
    try {
      Map<String, dynamic> deviceInfo = params.extendedInfo ?? {};
      
      if (deviceInfo.isEmpty) {
        final extended = await _deviceInfoService.getExtendedInfo();
        if (extended != null) {
          deviceInfo = extended.toJson();
        } else {
          deviceInfo = {'uuid': params.deviceId};
        }
      }

      if (params.alias != null) {
        deviceInfo['alias'] = params.alias;
      }

      return await _authRepository.registerDevice(deviceInfo);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
