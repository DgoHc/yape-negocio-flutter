
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_profile.dart';

/// Repositorio abstracto para autenticación y gestión de usuarios.
///
/// Define las operaciones de registro, login, inicio de prueba gratuita y obtención de perfil.
abstract class UserAuthRepository {
  /// Registra un nuevo usuario en el backend.
  Future<Either<Failure, ({String token, UserProfile profile})>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? businessType, // Rubro: transporte, librería, etc.
  });

  /// Inicia sesión con email y contraseña.
  Future<Either<Failure, ({String token, UserProfile profile})>> login({
    required String email,
    required String password,
  });

  /// Activa la prueba gratuita para el usuario autenticado.
  Future<Either<Failure, UserProfile>> startTrial();

  /// Obtiene el perfil del usuario autenticado.
  Future<Either<Failure, UserProfile>> getProfile();

  /// Actualiza el perfil del usuario autenticado.
  Future<Either<Failure, UserProfile>> updateProfile({
    String? name,
    String? phone,
    String? businessType,
  });

  /// Verifica el correo electrónico con el código OTP.
  Future<Either<Failure, ({String token, UserProfile profile})>> verifyEmail({
    required String email,
    required String code,
  });

  /// Reenvía el código OTP al correo.
  Future<Either<Failure, void>> resendOtp(String email);

  /// Inicia sesión con Google.
  Future<Either<Failure, ({String token, UserProfile profile})>> googleLogin({
    required String email,
    required String name,
    required String googleId,
  });

  /// Activa una suscripción para el usuario.
  Future<Either<Failure, UserProfile>> activateSubscription(UserProfile profile);
}
