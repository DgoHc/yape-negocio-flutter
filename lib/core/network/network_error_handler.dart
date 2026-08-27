
import 'package:dio/dio.dart';
import '../errors/failures.dart';

class NetworkErrorHandler {
  static Failure handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return const ServerFailure('El tiempo de conexión se ha agotado. Verifica tu internet.');
      case DioExceptionType.sendTimeout:
        return const ServerFailure('Error al enviar los datos. Inténtalo de nuevo.');
      case DioExceptionType.receiveTimeout:
        return const ServerFailure('El servidor tarda mucho en responder. Inténtalo más tarde.');
      case DioExceptionType.badResponse:
        final data = e.response?.data;
        if (data != null && data is Map) {
          // Capturar el mensaje personalizado del backend
          return ServerFailure(data['error']?.toString() ?? data['message']?.toString() ?? 'Error en la respuesta del servidor (${e.response?.statusCode})');
        }
        
        // Manejar códigos de estado comunes si no hay cuerpo de error
        switch (e.response?.statusCode) {
          case 400:
            return const ServerFailure('Petición incorrecta. Revisa los datos enviados.');
          case 401:
            return const AuthFailure('Sesión expirada o credenciales inválidas.');
          case 403:
            return const AuthFailure('No tienes permisos para realizar esta acción.');
          case 404:
            return const ServerFailure('El recurso solicitado no existe.');
          case 500:
            return const ServerFailure('Ocurrió un error interno en el servidor.');
          default:
            return ServerFailure('Error del servidor: ${e.response?.statusCode}');
        }
      case DioExceptionType.cancel:
        return const ServerFailure('La petición fue cancelada.');
      case DioExceptionType.connectionError:
        return const ServerFailure('No se pudo conectar con el servidor. ¿Estás en la misma red que el QNAP?');
      case DioExceptionType.unknown:
      default:
        if (e.message?.contains('SocketException') ?? false) {
          return const ServerFailure('Error de red. Verifica que el servidor QNAP esté encendido.');
        }
        return ServerFailure(e.message ?? 'Error de conexión desconocido.');
    }
  }

  static Failure handleGeneralError(dynamic e) {
    return ServerFailure('Ocurrió un error inesperado: ${e.toString()}');
  }
}
