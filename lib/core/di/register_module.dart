import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/network_config_service.dart';
import '../storage/drift/app_database.dart';
import '../storage/secure/token_manager.dart';
import '../config/env_config.dart';

@module
abstract class RegisterModule {
  @lazySingleton
  Connectivity get connectivity => Connectivity();

  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  @lazySingleton
  NetworkConfigService networkConfigService(
    SharedPreferences prefs,
  ) =>
      NetworkConfigService(prefs);

  @lazySingleton
  Dio dio(NetworkConfigService networkConfig, TokenManager tokenManager) {
    final dio = Dio(
      BaseOptions(
        baseUrl: EnvConfig.baseUrl,
        connectTimeout: Duration(milliseconds: EnvConfig.connectTimeout),
        receiveTimeout: Duration(milliseconds: EnvConfig.receiveTimeout),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // 1. Aplicar Base URL dinámica si existe
          final baseUrl = await networkConfig.getBaseUrl();
          if (baseUrl.isNotEmpty) options.baseUrl = baseUrl;

          // 2. Aplicar Token de autenticación
          final token = await tokenManager.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          
          return handler.next(options);
        },
        onResponse: (response, handler) async {
          // Guardar nuevo token si viene en headers (refresco automático)
          final newToken = response.headers.value('Authorization');
          if (newToken != null && newToken.startsWith('Bearer ')) {
            await tokenManager.saveToken(newToken.substring(7));
          }
          return handler.next(response);
        },
        onError: (e, handler) async {
          // Manejar expiración de token o falta de permisos
          if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
            // Limpiar token localmente si el servidor rechaza la sesión
            await tokenManager.deleteToken();
            // El router reaccionará al cambio de estado si el BLoC se actualiza
          }
          return handler.next(e);
        },
      ),
    );

    if (EnvConfig.isDebug) {
      dio.interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        error: true,
      ));
    }

    return dio;
  }

  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();

  @lazySingleton
  PaymentDao getPaymentDao(AppDatabase db) => db.paymentDao;

  @lazySingleton
  DeviceDao getDeviceDao(AppDatabase db) => db.deviceDao;

  @lazySingleton
  SyncDao getSyncDao(AppDatabase db) => db.syncDao;

  @lazySingleton
  SecondaryNumberDao getSecondaryNumberDao(AppDatabase db) => db.secondaryNumberDao;

  @lazySingleton
  UserProfileDao getUserProfileDao(AppDatabase db) => db.userProfileDao;
}
