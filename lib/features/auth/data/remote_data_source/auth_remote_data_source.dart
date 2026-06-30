
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/app_logger.dart';
import '../dtos/user_profile_dto.dart';

abstract class AuthRemoteDataSource {
  Future<Either<Failure, ({String token, UserProfileDto profile})>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? businessType,
  });

  Future<Either<Failure, ({String token, UserProfileDto profile})>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserProfileDto>> startTrial();

  Future<Either<Failure, UserProfileDto>> getProfile();

  Future<Either<Failure, UserProfileDto>> updateProfile({
    String? name,
    String? phone,
    String? businessType,
  });

  Future<Either<Failure, String>> loginAdmin(String username, String pin);

  Future<Either<Failure, bool>> checkDeviceStatus(String uuid);

  Future<Either<Failure, void>> registerDevice(Map<String, dynamic> deviceInfo);

  Future<Either<Failure, void>> unapproveDevice(String uuid);

  Future<Either<Failure, UserProfileDto>> activateSubscription(UserProfileDto profile);

  Future<Either<Failure, ({String token, UserProfileDto profile})>> verifyEmail({
    required String email,
    required String code,
  });

  Future<Either<Failure, void>> resendOtp(String email);

  Future<Either<Failure, ({String token, UserProfileDto profile})>> googleLogin({
    required String email,
    required String name,
    required String googleId,
  });
}

@Injectable(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl(this._dio);

  @override
  Future<Either<Failure, ({String token, UserProfileDto profile})>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? businessType,
  }) async {
    try {
      final response = await _dio.post('/users/register', data: {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'businessType': businessType,
      });

      final data = response.data;
      if (data is! Map) {
        throw Exception('Respuesta de registro inválida: Se esperaba un objeto');
      }

      final token = data['token']?.toString() ?? '';
      final profileDto = UserProfileDto.fromJson(Map<String, dynamic>.from(data));

      return Right((token: token, profile: profileDto));
    } on DioException catch (e) {
      return Left(ServerFailure(_extractErrorMessage(e)));
    } catch (e) {
      AppLogger.e('Error en register', e);
      return Left(ServerFailure('Error en registro: $e'));
    }
  }

  @override
  Future<Either<Failure, ({String token, UserProfileDto profile})>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/users/login', data: {
        'email': email,
        'password': password,
      });

      final data = response.data;
      if (data is! Map) {
        throw Exception('Respuesta de login inválida: Se esperaba un objeto');
      }

      final token = data['token']?.toString() ?? '';
      final profileDto = UserProfileDto.fromJson(Map<String, dynamic>.from(data));

      return Right((token: token, profile: profileDto));
    } on DioException catch (e) {
      return Left(ServerFailure(_extractErrorMessage(e)));
    } catch (e) {
      AppLogger.e('Error en login', e);
      return Left(ServerFailure('Error en inicio de sesión: $e'));
    }
  }

  @override
  Future<Either<Failure, UserProfileDto>> startTrial() async {
    try {
      final response = await _dio.post('/users/start-trial');
      final profileDto = _parseProfileResponse(response.data);
      return Right(profileDto);
    } on DioException catch (e) {
      return Left(ServerFailure(_extractErrorMessage(e)));
    } catch (e) {
      AppLogger.e('Error en startTrial', e);
      return Left(ServerFailure('Error al iniciar prueba: $e'));
    }
  }

  @override
  Future<Either<Failure, UserProfileDto>> getProfile() async {
    try {
      final response = await _dio.get('/users/profile');
      final profileDto = _parseProfileResponse(response.data);
      return Right(profileDto);
    } on DioException catch (e) {
      return Left(ServerFailure(_extractErrorMessage(e)));
    } catch (e) {
      AppLogger.e('Error en getProfile', e);
      return Left(ServerFailure('Error al obtener perfil: $e'));
    }
  }

  @override
  Future<Either<Failure, UserProfileDto>> updateProfile({
    String? name,
    String? phone,
    String? businessType,
  }) async {
    try {
      final response = await _dio.patch('/users/profile', data: {
        'name': name,
        'phone': phone,
        'businessType': businessType,
      });
      final profileDto = _parseProfileResponse(response.data);
      return Right(profileDto);
    } on DioException catch (e) {
      return Left(ServerFailure(_extractErrorMessage(e)));
    } catch (e) {
      AppLogger.e('Error en updateProfile', e);
      return Left(ServerFailure('Error al actualizar perfil: $e'));
    }
  }

  UserProfileDto _parseProfileResponse(dynamic data) {
    if (data == null) throw Exception('Respuesta del servidor vacía');
    
    Map<String, dynamic> json;
    if (data is List) {
      if (data.isEmpty) throw Exception('Lista de perfil vacía');
      if (data[0] is! Map) throw Exception('El elemento de la lista no es un objeto');
      json = Map<String, dynamic>.from(data[0] as Map);
    } else if (data is Map) {
      json = Map<String, dynamic>.from(data);
    } else {
      throw Exception('Formato de respuesta inesperado: ${data.runtimeType}');
    }
    
    return UserProfileDto.fromJson(json);
  }

  @override
  Future<Either<Failure, String>> loginAdmin(String username, String pin) async {
    try {
      final response = await _dio.post('/admin/login', data: {
        'username': username,
        'pin': pin,
      });
      
      final data = response.data;
      if (data is! Map) throw Exception('Respuesta admin login inválida');
      
      final token = data['token']?.toString() ?? '';
      return Right(token);
    } on DioException catch (e) {
      return Left(ServerFailure(_extractErrorMessage(e)));
    } catch (e) {
      AppLogger.e('Error en loginAdmin', e);
      return Left(ServerFailure('Error en login admin: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> checkDeviceStatus(String uuid) async {
    try {
      final response = await _dio.get('/devices/$uuid/status');
      final data = response.data;
      if (data is! Map) throw Exception('Respuesta status dispositivo inválida');
      
      final isApproved = data['isApproved'] as bool? ?? false;
      return Right(isApproved);
    } on DioException catch (e) {
      return Left(ServerFailure(_extractErrorMessage(e)));
    } catch (e) {
      AppLogger.e('Error en checkDeviceStatus', e);
      return Left(ServerFailure('Error al verificar dispositivo: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> registerDevice(Map<String, dynamic> deviceInfo) async {
    try {
      await _dio.post('/devices/register', data: deviceInfo);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(_extractErrorMessage(e)));
    } catch (e) {
      AppLogger.e('Error en registerDevice', e);
      return Left(ServerFailure('Error al registrar dispositivo: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> unapproveDevice(String uuid) async {
    try {
      await _dio.patch('/devices/$uuid/unapprove');
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(_extractErrorMessage(e)));
    } catch (e) {
      AppLogger.e('Error en unapproveDevice', e);
      return Left(ServerFailure('Error al desaprobar dispositivo: $e'));
    }
  }

  @override
  Future<Either<Failure, UserProfileDto>> activateSubscription(UserProfileDto profile) async {
    try {
      final response = await _dio.post('/users/activate-subscription', data: profile.toJson());
      return Right(_parseProfileResponse(response.data));
    } on DioException catch (e) {
      return Left(ServerFailure(_extractErrorMessage(e)));
    } catch (e) {
      AppLogger.e('Error en activateSubscription', e);
      return Left(ServerFailure('Error al activar suscripción: $e'));
    }
  }

  @override
  Future<Either<Failure, ({String token, UserProfileDto profile})>> verifyEmail({
    required String email,
    required String code,
  }) async {
    try {
      final response = await _dio.post('/users/verify-email', data: {
        'email': email,
        'code': code,
      });
      final data = response.data;
      final token = data['token']?.toString() ?? '';
      final profileDto = UserProfileDto.fromJson(Map<String, dynamic>.from(data));
      return Right((token: token, profile: profileDto));
    } on DioException catch (e) {
      return Left(ServerFailure(_extractErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resendOtp(String email) async {
    try {
      await _dio.post('/users/resend-otp', data: {'email': email});
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(_extractErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ({String token, UserProfileDto profile})>> googleLogin({
    required String email,
    required String name,
    required String googleId,
  }) async {
    try {
      final response = await _dio.post('/users/google-login', data: {
        'email': email,
        'name': name,
        'googleId': googleId,
      });
      final data = response.data;
      final token = data['token']?.toString() ?? '';
      final profileDto = UserProfileDto.fromJson(Map<String, dynamic>.from(data));
      return Right((token: token, profile: profileDto));
    } on DioException catch (e) {
      return Left(ServerFailure(_extractErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  String _extractErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data != null && data is Map) {
      return data['error']?.toString() ?? data['message']?.toString() ?? e.message ?? 'Error del servidor';
    }
    return e.message ?? 'Error desconocido';
  }
}
