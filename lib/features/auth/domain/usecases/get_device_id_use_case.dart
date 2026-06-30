
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/services/device_info_service.dart';

@injectable
class GetDeviceIdUseCase implements UseCase<String?, NoParams> {
  final DeviceInfoService _deviceInfoService;

  GetDeviceIdUseCase(this._deviceInfoService);

  @override
  Future<Either<Failure, String?>> call(NoParams params) async {
    try {
      final id = await _deviceInfoService.getDeviceUUID();
      return Right(id);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
