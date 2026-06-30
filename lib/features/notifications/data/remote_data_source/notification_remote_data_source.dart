
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/app_logger.dart';
import '../dtos/notification_link_dtos.dart';

abstract class NotificationRemoteDataSource {
  Future<Either<Failure, NotificationCodeDto>> getMyNotificationCode();
  Future<Either<Failure, Map<String, dynamic>>> findUserByCode(String code);
  Future<Either<Failure, LinkRequestDto>> sendLinkRequest(String code);
  Future<Either<Failure, List<LinkRequestDto>>> getLinkRequests();
  Future<Either<Failure, void>> acceptLinkRequest(String requestId);
  Future<Either<Failure, void>> rejectLinkRequest(String requestId);
  Future<Either<Failure, List<UserLinkDto>>> getLinkedUsers();
  Future<Either<Failure, UserLinkDto>> updateLink(String linkId, String? alias, String? status);
  Future<Either<Failure, void>> deleteLink(String linkId);
  Future<Either<Failure, void>> registerFcmToken(String token, String? deviceId, String? deviceName);
}

@Injectable(as: NotificationRemoteDataSource)
class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final Dio _dio;

  NotificationRemoteDataSourceImpl(this._dio);

  @override
  Future<Either<Failure, NotificationCodeDto>> getMyNotificationCode() async {
    try {
      final response = await _dio.get('/notifications/code');
      return Right(NotificationCodeDto.fromJson(Map<String, dynamic>.from(response.data)));
    } on DioException catch (e) {
      return Left(ServerFailure(_extractErrorMessage(e)));
    } catch (e) {
      AppLogger.e('Error getting notification code', e);
      return Left(ServerFailure('Error al obtener código: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> findUserByCode(String code) async {
    try {
      final response = await _dio.get('/notifications/find-user/$code');
      return Right(Map<String, dynamic>.from(response.data));
    } on DioException catch (e) {
      return Left(ServerFailure(_extractErrorMessage(e)));
    } catch (e) {
      AppLogger.e('Error finding user by code', e);
      return Left(ServerFailure('Error al buscar usuario: $e'));
    }
  }

  @override
  Future<Either<Failure, LinkRequestDto>> sendLinkRequest(String code) async {
    try {
      final response = await _dio.post('/notifications/link-request', data: {'code': code});
      return Right(LinkRequestDto.fromJson(Map<String, dynamic>.from(response.data)));
    } on DioException catch (e) {
      return Left(ServerFailure(_extractErrorMessage(e)));
    } catch (e) {
      AppLogger.e('Error sending link request', e);
      return Left(ServerFailure('Error al enviar solicitud: $e'));
    }
  }

  @override
  Future<Either<Failure, List<LinkRequestDto>>> getLinkRequests() async {
    try {
      final response = await _dio.get('/notifications/link-requests');
      final data = response.data as List;
      final requests = data.map((item) => LinkRequestDto.fromJson(Map<String, dynamic>.from(item))).toList();
      return Right(requests);
    } on DioException catch (e) {
      return Left(ServerFailure(_extractErrorMessage(e)));
    } catch (e) {
      AppLogger.e('Error getting link requests', e);
      return Left(ServerFailure('Error al obtener solicitudes: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> acceptLinkRequest(String requestId) async {
    try {
      await _dio.post('/notifications/link-requests/$requestId/accept');
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(_extractErrorMessage(e)));
    } catch (e) {
      AppLogger.e('Error accepting link request', e);
      return Left(ServerFailure('Error al aceptar solicitud: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> rejectLinkRequest(String requestId) async {
    try {
      await _dio.post('/notifications/link-requests/$requestId/reject');
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(_extractErrorMessage(e)));
    } catch (e) {
      AppLogger.e('Error rejecting link request', e);
      return Left(ServerFailure('Error al rechazar solicitud: $e'));
    }
  }

  @override
  Future<Either<Failure, List<UserLinkDto>>> getLinkedUsers() async {
    try {
      final response = await _dio.get('/notifications/linked-users');
      final data = response.data as List;
      final links = data.map((item) => UserLinkDto.fromJson(Map<String, dynamic>.from(item))).toList();
      return Right(links);
    } on DioException catch (e) {
      return Left(ServerFailure(_extractErrorMessage(e)));
    } catch (e) {
      AppLogger.e('Error getting linked users', e);
      return Left(ServerFailure('Error al obtener usuarios vinculados: $e'));
    }
  }

  @override
  Future<Either<Failure, UserLinkDto>> updateLink(String linkId, String? alias, String? status) async {
    try {
      final response = await _dio.patch('/notifications/links/$linkId', data: {'alias': alias, 'status': status});
      return Right(UserLinkDto.fromJson(Map<String, dynamic>.from(response.data)));
    } on DioException catch (e) {
      return Left(ServerFailure(_extractErrorMessage(e)));
    } catch (e) {
      AppLogger.e('Error updating link', e);
      return Left(ServerFailure('Error al actualizar vinculación: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteLink(String linkId) async {
    try {
      await _dio.delete('/notifications/links/$linkId');
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(_extractErrorMessage(e)));
    } catch (e) {
      AppLogger.e('Error deleting link', e);
      return Left(ServerFailure('Error al eliminar vinculación: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> registerFcmToken(String token, String? deviceId, String? deviceName) async {
    try {
      await _dio.post('/notifications/fcm-token', data: {
        'token': token,
        'deviceId': deviceId,
        'deviceName': deviceName,
      });
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(_extractErrorMessage(e)));
    } catch (e) {
      AppLogger.e('Error registering FCM token', e);
      return Left(ServerFailure('Error al registrar token FCM: $e'));
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
