
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/storage/secure/token_manager.dart';
import '../entities/auth_status_result.dart';
import '../repositories/user_profile_repository.dart';
import 'get_device_id_use_case.dart';

@injectable
class CheckAuthStatusUseCase implements UseCase<CheckAuthStatusResult, NoParams> {
  final TokenManager _tokenManager;
  final UserProfileRepository _userProfileRepository;
  final GetDeviceIdUseCase _getDeviceIdUseCase;

  CheckAuthStatusUseCase(
    this._tokenManager,
    this._userProfileRepository,
    this._getDeviceIdUseCase,
  );

  @override
  Future<Either<Failure, CheckAuthStatusResult>> call(NoParams params) async {
    final deviceIdEither = await _getDeviceIdUseCase(params);
    final String? deviceId = await deviceIdEither.fold((_) => null, (id) => id);

    // 1. Verificar si hay un Token válido
    final hasValidToken = await _tokenManager.isTokenValid();
    if (!hasValidToken) {
      final profile = await _userProfileRepository.getProfile();
      final errorMsg = profile != null ? 'Tu sesión ha expirado. Por favor, inicia sesión de nuevo.' : null;
      return Right(CheckAuthStatusResult(
        status: AuthStatusResult.unauthenticated,
        error: errorMsg,
        deviceId: deviceId,
      ));
    }

    final role = await _tokenManager.getUserRole();
    
    // Si el rol es administrativo, devolvemos authenticatedAdmin
    if (role == 'ADMIN' || role == 'SUPER_ADMIN' || role == 'SUPERVISOR') {
      final profile = await _userProfileRepository.getProfile();
      return Right(CheckAuthStatusResult(
        status: AuthStatusResult.authenticatedAdmin,
        userRole: role,
        deviceId: deviceId,
        userProfile: profile,
      ));
    }

    // 2. Si no es admin, verificar perfil local (Conductor)
    final profile = await _userProfileRepository.getProfile();

    if (profile == null) {
      return Right(CheckAuthStatusResult(
        status: AuthStatusResult.unauthenticated,
        deviceId: deviceId,
      ));
    }

    // 3. Verificar acceso (Suscripción/Prueba)
    if (!profile.hasAccess) {
      return Right(CheckAuthStatusResult(
        status: AuthStatusResult.noAccess,
        userProfile: profile,
        deviceId: deviceId,
      ));
    }

    // 4. Si tiene perfil y acceso, está autenticado
    return Right(CheckAuthStatusResult(
      status: AuthStatusResult.authenticatedDriver,
      deviceId: deviceId,
      userProfile: profile,
    ));
  }
}
