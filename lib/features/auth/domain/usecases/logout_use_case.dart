
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/storage/secure/token_manager.dart';
import '../../../../core/services/device_info_service.dart';
import '../../../../core/storage/drift/app_database.dart';
import '../repositories/auth_repository.dart';
import '../repositories/device_repository.dart';

@injectable
class LogoutUseCase implements UseCase<void, NoParams> {
  final TokenManager _tokenManager;
  final AuthRepository _authRepository;
  final DeviceRepository _deviceRepository;
  final DeviceInfoService _deviceInfoService;
  final AppDatabase _db;

  LogoutUseCase(
    this._tokenManager,
    this._authRepository,
    this._deviceRepository,
    this._deviceInfoService,
    this._db,
  );

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    try {
      final deviceIdEither = await _deviceInfoService.getDeviceUUID();
      
      await _tokenManager.deleteToken();

      // Limpiar datos locales al cerrar sesión para privacidad
      await _db.paymentDao.deleteAllPayments();
      await _db.userProfileDao.deleteProfile();

      if (deviceIdEither != null) {
        await _authRepository.unapproveDevice(deviceIdEither);
        final localDevice = await _deviceRepository.getDeviceByUuid(deviceIdEither);
        if (localDevice != null) {
          await _deviceRepository.upsertDevice(
            uuid: deviceIdEither,
            alias: localDevice.alias,
            isApproved: false,
          );
        }
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
