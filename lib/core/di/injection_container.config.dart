// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../features/admin/data/remote_data_source/admin_remote_data_source.dart'
    as _i660;
import '../../features/admin/data/repositories/admin_repository_impl.dart'
    as _i335;
import '../../features/admin/domain/repositories/admin_repository.dart'
    as _i583;
import '../../features/admin/domain/usecases/create_user_use_case.dart'
    as _i298;
import '../../features/admin/domain/usecases/delete_device_use_case.dart'
    as _i743;
import '../../features/admin/domain/usecases/delete_user_use_case.dart'
    as _i385;
import '../../features/admin/domain/usecases/export_admin_data_use_case.dart'
    as _i290;
import '../../features/admin/domain/usecases/get_devices_use_case.dart'
    as _i873;
import '../../features/admin/domain/usecases/get_user_profiles_use_case.dart'
    as _i765;
import '../../features/admin/domain/usecases/get_users_use_case.dart' as _i852;
import '../../features/admin/domain/usecases/register_device_manual_use_case.dart'
    as _i328;
import '../../features/admin/domain/usecases/update_device_status_use_case.dart'
    as _i463;
import '../../features/admin/domain/usecases/update_user_profile_subscription_use_case.dart'
    as _i332;
import '../../features/admin/domain/usecases/update_user_use_case.dart'
    as _i614;
import '../../features/admin/presentation/bloc/admin_bloc.dart' as _i55;
import '../../features/auth/data/local_data_source/auth_local_data_source.dart'
    as _i973;
import '../../features/auth/data/remote_data_source/auth_remote_data_source.dart'
    as _i203;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/data/repositories/device_repository_impl.dart'
    as _i921;
import '../../features/auth/data/repositories/payment_gateway_repository_impl.dart'
    as _i88;
import '../../features/auth/data/repositories/remember_me_repository_impl.dart'
    as _i368;
import '../../features/auth/data/repositories/user_auth_repository_impl.dart'
    as _i843;
import '../../features/auth/data/repositories/user_profile_repository_impl.dart'
    as _i1058;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/domain/repositories/device_repository.dart'
    as _i784;
import '../../features/auth/domain/repositories/payment_gateway_repository.dart'
    as _i544;
import '../../features/auth/domain/repositories/remember_me_repository.dart'
    as _i373;
import '../../features/auth/domain/repositories/user_auth_repository.dart'
    as _i843;
import '../../features/auth/domain/repositories/user_profile_repository.dart'
    as _i154;
import '../../features/auth/domain/usecases/activate_subscription_use_case.dart'
    as _i813;
import '../../features/auth/domain/usecases/approve_device_use_case.dart'
    as _i506;
import '../../features/auth/domain/usecases/check_auth_status_use_case.dart'
    as _i489;
import '../../features/auth/domain/usecases/check_device_status_use_case.dart'
    as _i1063;
import '../../features/auth/domain/usecases/get_device_id_use_case.dart'
    as _i750;
import '../../features/auth/domain/usecases/login_admin_use_case.dart' as _i761;
import '../../features/auth/domain/usecases/login_user_use_case.dart' as _i2;
import '../../features/auth/domain/usecases/logout_use_case.dart' as _i711;
import '../../features/auth/domain/usecases/register_device_use_case.dart'
    as _i100;
import '../../features/auth/domain/usecases/register_user_use_case.dart'
    as _i468;
import '../../features/auth/domain/usecases/start_trial_use_case.dart' as _i491;
import '../../features/auth/domain/usecases/update_profile_use_case.dart'
    as _i659;
import '../../features/auth/presentation/bloc/auth_bloc.dart' as _i797;
import '../../features/connectivity/presentation/bloc/connectivity_bloc.dart'
    as _i78;
import '../../features/notifications/data/notification_platform_service.dart'
    as _i611;
import '../../features/notifications/data/remote_data_source/notification_remote_data_source.dart'
    as _i953;
import '../../features/notifications/data/repositories/notification_repository_impl.dart'
    as _i361;
import '../../features/notifications/domain/parsers/payment_parser.dart'
    as _i844;
import '../../features/notifications/domain/repositories/notification_repository.dart'
    as _i367;
import '../../features/notifications/presentation/bloc/notification_bloc.dart'
    as _i876;
import '../../features/payments/data/local_data_source/payment_local_data_source.dart'
    as _i712;
import '../../features/payments/data/remote_data_source/payment_remote_data_source.dart'
    as _i943;
import '../../features/payments/data/repositories/payment_repository_impl.dart'
    as _i842;
import '../../features/payments/domain/repositories/payment_repository.dart'
    as _i315;
import '../../features/payments/domain/usecases/export_payments_use_case.dart'
    as _i997;
import '../../features/payments/presentation/bloc/payments_bloc.dart' as _i511;
import '../../features/settings/presentation/bloc/settings_bloc.dart' as _i585;
import '../network/network_config_service.dart' as _i167;
import '../services/device_info_service.dart' as _i335;
import '../services/export_service.dart' as _i26;
import '../services/google_auth_service.dart' as _i947;
import '../services/tts_service.dart' as _i27;
import '../storage/drift/app_database.dart' as _i723;
import '../storage/secure/db_encryption_service.dart' as _i871;
import '../storage/secure/pin_manager.dart' as _i370;
import '../storage/secure/token_manager.dart' as _i675;
import '../sync/sync_engine.dart' as _i846;
import 'register_module.dart' as _i291;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => registerModule.prefs,
      preResolve: true,
    );
    gh.lazySingleton<_i895.Connectivity>(() => registerModule.connectivity);
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => registerModule.secureStorage,
    );
    gh.lazySingleton<_i335.DeviceInfoService>(() => _i335.DeviceInfoService());
    gh.lazySingleton<_i26.ExportService>(() => _i26.ExportService());
    gh.lazySingleton<_i947.GoogleAuthService>(() => _i947.GoogleAuthService());
    gh.lazySingleton<_i27.TtsService>(() => _i27.TtsService());
    gh.lazySingleton<_i723.AppDatabase>(() => _i723.AppDatabase());
    gh.lazySingleton<_i611.NotificationPlatformService>(
      () => _i611.NotificationPlatformService(),
    );
    gh.lazySingleton<_i844.PaymentParser>(() => _i844.PaymentParser());
    gh.factory<_i750.GetDeviceIdUseCase>(
      () => _i750.GetDeviceIdUseCase(gh<_i335.DeviceInfoService>()),
    );
    gh.lazySingleton<_i871.DbEncryptionService>(
      () => _i871.DbEncryptionService(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i370.PinManager>(
      () => _i370.PinManager(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i675.TokenManager>(
      () => _i675.TokenManager(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i78.ConnectivityBloc>(
      () => _i78.ConnectivityBloc(gh<_i895.Connectivity>()),
    );
    gh.lazySingleton<_i290.ExportAdminDataUseCase>(
      () => _i290.ExportAdminDataUseCase(gh<_i26.ExportService>()),
    );
    gh.lazySingleton<_i997.ExportPaymentsUseCase>(
      () => _i997.ExportPaymentsUseCase(gh<_i26.ExportService>()),
    );
    gh.lazySingleton<_i723.PaymentDao>(
      () => registerModule.getPaymentDao(gh<_i723.AppDatabase>()),
    );
    gh.lazySingleton<_i723.DeviceDao>(
      () => registerModule.getDeviceDao(gh<_i723.AppDatabase>()),
    );
    gh.lazySingleton<_i723.SyncDao>(
      () => registerModule.getSyncDao(gh<_i723.AppDatabase>()),
    );
    gh.lazySingleton<_i723.SecondaryNumberDao>(
      () => registerModule.getSecondaryNumberDao(gh<_i723.AppDatabase>()),
    );
    gh.lazySingleton<_i723.UserProfileDao>(
      () => registerModule.getUserProfileDao(gh<_i723.AppDatabase>()),
    );
    gh.factory<_i973.AuthLocalDataSource>(
      () => _i973.AuthLocalDataSourceImpl(
        gh<_i723.UserProfileDao>(),
        gh<_i723.DeviceDao>(),
      ),
    );
    gh.lazySingleton<_i167.NetworkConfigService>(
      () => registerModule.networkConfigService(gh<_i460.SharedPreferences>()),
    );
    gh.factory<_i373.RememberMeRepository>(
      () => _i368.RememberMeRepositoryImpl(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i712.PaymentLocalDataSource>(
      () => _i712.PaymentLocalDataSourceImpl(gh<_i723.AppDatabase>()),
    );
    gh.factory<_i154.UserProfileRepository>(
      () => _i1058.UserProfileRepositoryImpl(gh<_i973.AuthLocalDataSource>()),
    );
    gh.factory<_i784.DeviceRepository>(
      () => _i921.DeviceRepositoryImpl(gh<_i973.AuthLocalDataSource>()),
    );
    gh.lazySingleton<_i361.Dio>(
      () => registerModule.dio(
        gh<_i167.NetworkConfigService>(),
        gh<_i675.TokenManager>(),
      ),
    );
    gh.factory<_i489.CheckAuthStatusUseCase>(
      () => _i489.CheckAuthStatusUseCase(
        gh<_i675.TokenManager>(),
        gh<_i154.UserProfileRepository>(),
        gh<_i750.GetDeviceIdUseCase>(),
      ),
    );
    gh.factory<_i660.AdminRemoteDataSource>(
      () => _i660.AdminRemoteDataSourceImpl(
        gh<_i361.Dio>(),
        gh<_i675.TokenManager>(),
      ),
    );
    gh.factory<_i585.SettingsBloc>(
      () => _i585.SettingsBloc(
        gh<_i723.SecondaryNumberDao>(),
        gh<_i723.UserProfileDao>(),
        gh<_i167.NetworkConfigService>(),
        gh<_i27.TtsService>(),
        gh<_i460.SharedPreferences>(),
      ),
    );
    gh.factory<_i953.NotificationRemoteDataSource>(
      () => _i953.NotificationRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i943.PaymentRemoteDataSource>(
      () => _i943.PaymentRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.factory<_i544.PaymentGatewayRepository>(
      () => _i88.PaymentGatewayRepositoryImpl(gh<_i361.Dio>()),
    );
    gh.factory<_i583.AdminRepository>(
      () => _i335.AdminRepositoryImpl(gh<_i660.AdminRemoteDataSource>()),
    );
    gh.factory<_i203.AuthRemoteDataSource>(
      () => _i203.AuthRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i787.AuthRepository>(
      () => _i153.AuthRepositoryImpl(
        gh<_i203.AuthRemoteDataSource>(),
        gh<_i675.TokenManager>(),
        gh<_i361.Dio>(),
      ),
    );
    gh.factory<_i711.LogoutUseCase>(
      () => _i711.LogoutUseCase(
        gh<_i675.TokenManager>(),
        gh<_i787.AuthRepository>(),
        gh<_i784.DeviceRepository>(),
        gh<_i335.DeviceInfoService>(),
      ),
    );
    gh.factory<_i506.ApproveDeviceUseCase>(
      () => _i506.ApproveDeviceUseCase(
        gh<_i787.AuthRepository>(),
        gh<_i335.DeviceInfoService>(),
      ),
    );
    gh.factory<_i843.UserAuthRepository>(
      () => _i843.UserAuthRepositoryImpl(
        gh<_i203.AuthRemoteDataSource>(),
        gh<_i675.TokenManager>(),
      ),
    );
    gh.lazySingleton<_i298.CreateUserUseCase>(
      () => _i298.CreateUserUseCase(gh<_i583.AdminRepository>()),
    );
    gh.lazySingleton<_i743.DeleteDeviceUseCase>(
      () => _i743.DeleteDeviceUseCase(gh<_i583.AdminRepository>()),
    );
    gh.lazySingleton<_i385.DeleteUserUseCase>(
      () => _i385.DeleteUserUseCase(gh<_i583.AdminRepository>()),
    );
    gh.lazySingleton<_i873.GetDevicesUseCase>(
      () => _i873.GetDevicesUseCase(gh<_i583.AdminRepository>()),
    );
    gh.lazySingleton<_i765.GetUserProfilesUseCase>(
      () => _i765.GetUserProfilesUseCase(gh<_i583.AdminRepository>()),
    );
    gh.lazySingleton<_i852.GetUsersUseCase>(
      () => _i852.GetUsersUseCase(gh<_i583.AdminRepository>()),
    );
    gh.lazySingleton<_i328.RegisterDeviceManualUseCase>(
      () => _i328.RegisterDeviceManualUseCase(gh<_i583.AdminRepository>()),
    );
    gh.lazySingleton<_i463.UpdateDeviceStatusUseCase>(
      () => _i463.UpdateDeviceStatusUseCase(gh<_i583.AdminRepository>()),
    );
    gh.lazySingleton<_i332.UpdateUserProfileSubscriptionUseCase>(
      () => _i332.UpdateUserProfileSubscriptionUseCase(
        gh<_i583.AdminRepository>(),
      ),
    );
    gh.lazySingleton<_i614.UpdateUserUseCase>(
      () => _i614.UpdateUserUseCase(gh<_i583.AdminRepository>()),
    );
    gh.factory<_i367.NotificationRepository>(
      () => _i361.NotificationRepositoryImpl(
        gh<_i953.NotificationRemoteDataSource>(),
      ),
    );
    gh.factory<_i2.LoginUserUseCase>(
      () => _i2.LoginUserUseCase(gh<_i843.UserAuthRepository>()),
    );
    gh.factory<_i468.RegisterUserUseCase>(
      () => _i468.RegisterUserUseCase(gh<_i843.UserAuthRepository>()),
    );
    gh.factory<_i491.StartTrialUseCase>(
      () => _i491.StartTrialUseCase(gh<_i843.UserAuthRepository>()),
    );
    gh.factory<_i659.UpdateProfileUseCase>(
      () => _i659.UpdateProfileUseCase(gh<_i843.UserAuthRepository>()),
    );
    gh.factory<_i55.AdminBloc>(
      () => _i55.AdminBloc(
        gh<_i873.GetDevicesUseCase>(),
        gh<_i852.GetUsersUseCase>(),
        gh<_i765.GetUserProfilesUseCase>(),
        gh<_i332.UpdateUserProfileSubscriptionUseCase>(),
        gh<_i328.RegisterDeviceManualUseCase>(),
        gh<_i463.UpdateDeviceStatusUseCase>(),
        gh<_i743.DeleteDeviceUseCase>(),
        gh<_i298.CreateUserUseCase>(),
        gh<_i614.UpdateUserUseCase>(),
        gh<_i385.DeleteUserUseCase>(),
        gh<_i290.ExportAdminDataUseCase>(),
      ),
    );
    gh.lazySingleton<_i315.PaymentRepository>(
      () => _i842.PaymentRepositoryImpl(
        gh<_i943.PaymentRemoteDataSource>(),
        gh<_i712.PaymentLocalDataSource>(),
        gh<_i78.ConnectivityBloc>(),
        gh<_i611.NotificationPlatformService>(),
        gh<_i27.TtsService>(),
        gh<_i723.SecondaryNumberDao>(),
        gh<_i723.SyncDao>(),
        gh<_i723.UserProfileDao>(),
        gh<_i460.SharedPreferences>(),
      ),
    );
    gh.lazySingleton<_i1063.CheckDeviceStatusUseCase>(
      () => _i1063.CheckDeviceStatusUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i761.LoginAdminUseCase>(
      () => _i761.LoginAdminUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i100.RegisterDeviceUseCase>(
      () => _i100.RegisterDeviceUseCase(gh<_i787.AuthRepository>()),
    );
    gh.factory<_i876.NotificationBloc>(
      () => _i876.NotificationBloc(gh<_i367.NotificationRepository>()),
    );
    gh.factory<_i813.ActivateSubscriptionUseCase>(
      () => _i813.ActivateSubscriptionUseCase(
        gh<_i843.UserAuthRepository>(),
        gh<_i154.UserProfileRepository>(),
      ),
    );
    gh.lazySingleton<_i846.SyncEngine>(
      () => _i846.SyncEngine(
        gh<_i723.SyncDao>(),
        gh<_i78.ConnectivityBloc>(),
        gh<_i315.PaymentRepository>(),
        gh<_i787.AuthRepository>(),
      ),
    );
    gh.factory<_i511.PaymentsBloc>(
      () => _i511.PaymentsBloc(
        gh<_i315.PaymentRepository>(),
        gh<_i997.ExportPaymentsUseCase>(),
      ),
    );
    gh.factory<_i797.AuthBloc>(
      () => _i797.AuthBloc(
        gh<_i761.LoginAdminUseCase>(),
        gh<_i468.RegisterUserUseCase>(),
        gh<_i2.LoginUserUseCase>(),
        gh<_i491.StartTrialUseCase>(),
        gh<_i813.ActivateSubscriptionUseCase>(),
        gh<_i489.CheckAuthStatusUseCase>(),
        gh<_i711.LogoutUseCase>(),
        gh<_i750.GetDeviceIdUseCase>(),
        gh<_i659.UpdateProfileUseCase>(),
        gh<_i154.UserProfileRepository>(),
        gh<_i544.PaymentGatewayRepository>(),
        gh<_i373.RememberMeRepository>(),
        gh<_i947.GoogleAuthService>(),
        gh<_i843.UserAuthRepository>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}
