import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/storage/secure/token_manager.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/auth_status_result.dart';
import '../../domain/usecases/login_admin_use_case.dart';
import '../../domain/usecases/register_user_use_case.dart';
import '../../domain/usecases/login_user_use_case.dart';
import '../../domain/usecases/start_trial_use_case.dart';
import '../../domain/usecases/activate_subscription_use_case.dart';
import '../../domain/usecases/check_auth_status_use_case.dart';
import '../../domain/usecases/logout_use_case.dart';
import '../../domain/usecases/approve_device_use_case.dart';
import '../../domain/usecases/get_device_id_use_case.dart';
import '../../domain/usecases/update_profile_use_case.dart';
import '../../domain/usecases/forgot_password_use_case.dart';
import '../../domain/usecases/reset_password_use_case.dart';
import '../../domain/repositories/user_profile_repository.dart';

import '../../domain/repositories/remember_me_repository.dart';
import '../../domain/repositories/user_auth_repository.dart';
import '../../domain/entities/payment_provider.dart';
import '../../../../core/services/google_auth_service.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {
  const AppStarted();
}

class ClearError extends AuthEvent {
  const ClearError();
}

class ResetAuthStatus extends AuthEvent {
  const ResetAuthStatus();
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

class AdminLoginRequested extends AuthEvent {
  final String username;
  final String pin;

  const AdminLoginRequested({required this.username, required this.pin});

  @override
  List<Object?> get props => [username, pin];
}

class LoginUserRequested extends AuthEvent {
  final String email;
  final String password;
  final bool rememberMe;

  const LoginUserRequested({
    required this.email, 
    required this.password,
    this.rememberMe = false,
  });

  @override
  List<Object?> get props => [email, password, rememberMe];
}

class GoogleLoginRequested extends AuthEvent {
  const GoogleLoginRequested();
}

class CheckStatusRequested extends AuthEvent {
  const CheckStatusRequested();
}

class RegisterUser extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String? phone;
  final String? businessType;

  const RegisterUser({
    required this.name,
    required this.email,
    required this.password,
    this.phone,
    this.businessType,
  });

  @override
  List<Object?> get props => [name, email, password, phone, businessType];
}

class VerifyEmailRequested extends AuthEvent {
  final String email;
  final String code;

  const VerifyEmailRequested({required this.email, required this.code});

  @override
  List<Object?> get props => [email, code];
}

class ResendOtpRequested extends AuthEvent {
  final String email;

  const ResendOtpRequested(this.email);

  @override
  List<Object?> get props => [email];
}

class ForgotPasswordRequested extends AuthEvent {
  final String email;

  const ForgotPasswordRequested(this.email);

  @override
  List<Object?> get props => [email];
}

class ResetPasswordRequested extends AuthEvent {
  final String email;
  final String code;
  final String newPassword;

  const ResetPasswordRequested({
    required this.email,
    required this.code,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [email, code, newPassword];
}

class StartTrial extends AuthEvent {
  const StartTrial();
}

class Subscribe extends AuthEvent {
  final PaymentProvider? provider;
  final double amount;

  const Subscribe({this.provider, required this.amount});

  @override
  List<Object?> get props => [provider, amount];
}

class UpdateProfile extends AuthEvent {
  final String? name;
  final String? phone;
  final String? businessType;

  const UpdateProfile({
    this.name,
    this.phone,
    this.businessType,
  });

  @override
  List<Object?> get props => [name, phone, businessType];
}

// States
enum AuthStatus {
  initial,
  authenticatedAdmin,
  authenticatedDriver,
  unauthenticated,
  needsPairing,
  needsSubscription,
  needsRegistration,
  needsVerification,
  forgotPasswordOtpSent,
  passwordResetSuccess,
  loading,
  noAccess,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final String? error;
  final String? message;
  final String? userRole;
  final String? deviceId;
  final String? rememberedEmail;
  final DateTime? timestamp;
  final UserProfile? userProfile;

  const AuthState({
    this.status = AuthStatus.initial,
    this.error,
    this.message,
    this.userRole,
    this.deviceId,
    this.rememberedEmail,
    this.timestamp,
    this.userProfile,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? error,
    String? message,
    String? userRole,
    String? deviceId,
    String? rememberedEmail,
    DateTime? timestamp,
    UserProfile? userProfile,
  }) {
    return AuthState(
      status: status ?? this.status,
      error: error,
      message: message,
      userRole: userRole ?? this.userRole,
      deviceId: deviceId ?? this.deviceId,
      rememberedEmail: rememberedEmail ?? this.rememberedEmail,
      timestamp: timestamp ?? this.timestamp,
      userProfile: userProfile ?? this.userProfile,
    );
  }

  @override
  List<Object?> get props => [status, error, message, userRole, deviceId, rememberedEmail, timestamp, userProfile];
}

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginAdminUseCase _loginAdminUseCase;
  final RegisterUserUseCase _registerUserUseCase;
  final LoginUserUseCase _loginUserUseCase;
  final StartTrialUseCase _startTrialUseCase;
  final ActivateSubscriptionUseCase _activateSubscriptionUseCase;
  final CheckAuthStatusUseCase _checkAuthStatusUseCase;
  final LogoutUseCase _logoutUseCase;
  final ApproveDeviceUseCase _approveDeviceUseCase;
  final GetDeviceIdUseCase _getDeviceIdUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final ForgotPasswordUseCase _forgotPasswordUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;
  final UserProfileRepository _userProfileRepository;
  final RememberMeRepository _rememberMeRepository;
  final GoogleAuthService _googleAuthService;
  final UserAuthRepository _userAuthRepository;
  final TokenManager _tokenManager;

  AuthBloc(
    this._loginAdminUseCase,
    this._registerUserUseCase,
    this._loginUserUseCase,
    this._startTrialUseCase,
    this._activateSubscriptionUseCase,
    this._checkAuthStatusUseCase,
    this._logoutUseCase,
    this._approveDeviceUseCase,
    this._getDeviceIdUseCase,
    this._updateProfileUseCase,
    this._forgotPasswordUseCase,
    this._resetPasswordUseCase,
    this._userProfileRepository,
    this._rememberMeRepository,
    this._googleAuthService,
    this._userAuthRepository,
    this._tokenManager,
  ) : super(const AuthState()) {
    on<AppStarted>(_onAppStarted);
    on<AdminLoginRequested>(_onAdminLoginRequested);
    on<LoginUserRequested>(_onLoginUserRequested);
    on<GoogleLoginRequested>(_onGoogleLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckStatusRequested>(_onCheckStatusRequested);
    on<RegisterUser>(_onRegisterUser);
    on<VerifyEmailRequested>(_onVerifyEmailRequested);
    on<ResendOtpRequested>(_onResendOtpRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
    on<StartTrial>(_onStartTrial);
    on<Subscribe>(_onSubscribe);
    on<UpdateProfile>(_onUpdateProfile);
    on<ClearError>(_onClearError);
    on<ResetAuthStatus>(_onResetAuthStatus);
  }

  void _onResetAuthStatus(ResetAuthStatus event, Emitter<AuthState> emit) {
    emit(state.copyWith(status: AuthStatus.unauthenticated));
  }

  void _onClearError(ClearError event, Emitter<AuthState> emit) {
    emit(state.copyWith(error: null, message: null));
  }

  Future<void> _onAdminLoginRequested(AdminLoginRequested event, Emitter<AuthState> emit) async {
    AppLogger.d('AuthBloc: Intentando login de admin para ${event.username}');
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await _loginAdminUseCase(event.username, event.pin);
    result.fold(
      (failure) {
        AppLogger.e('AuthBloc: Error en login de admin: ${failure.message}');
        emit(state.copyWith(status: AuthStatus.unauthenticated, error: failure.message));
      },
      (token) {
        AppLogger.i('AuthBloc: Login de admin exitoso');
        add(const AppStarted());
      },
    );
  }

  Future<void> _onCheckStatusRequested(CheckStatusRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    add(const AppStarted());
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final rememberedEmail = await _rememberMeRepository.getEmail();
    final result = await _checkAuthStatusUseCase(const NoParams());
    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.unauthenticated, 
        error: failure.message,
        rememberedEmail: rememberedEmail,
      )),
      (authResult) => emit(_mapResultToState(authResult).copyWith(
        rememberedEmail: rememberedEmail,
      )),
    );
  }

  AuthState _mapResultToState(CheckAuthStatusResult result) {
    AuthStatus status;
    switch (result.status) {
      case AuthStatusResult.authenticatedAdmin:
        status = AuthStatus.authenticatedAdmin;
        break;
      case AuthStatusResult.authenticatedDriver:
        status = AuthStatus.authenticatedDriver;
        break;
      case AuthStatusResult.needsPairing:
        status = AuthStatus.needsPairing;
        break;
      case AuthStatusResult.needsSubscription:
        status = AuthStatus.needsSubscription;
        break;
      case AuthStatusResult.noAccess:
        status = AuthStatus.noAccess;
        break;
      case AuthStatusResult.unauthenticated:
      case AuthStatusResult.initial:
        status = AuthStatus.unauthenticated;
        break;
    }
    return AuthState(
      status: status,
      error: result.error,
      userRole: result.userRole,
      deviceId: result.deviceId,
      timestamp: DateTime.now(),
      userProfile: result.userProfile,
    );
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    await _logoutUseCase(const NoParams());
    emit(state.copyWith(
      status: AuthStatus.unauthenticated,
      userProfile: null,
      userRole: null,
    ));
  }

  Future<void> _onRegisterUser(RegisterUser event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await _registerUserUseCase(
      RegisterUserParams(
        name: event.name,
        email: event.email,
        password: event.password,
        phone: event.phone,
        businessType: event.businessType,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        error: failure.message,
      )),
      (data) {
        emit(state.copyWith(
          status: AuthStatus.needsVerification,
          userProfile: data.profile,
          error: null,
          rememberedEmail: event.email,
        ));
      },
    );
  }

  Future<void> _onVerifyEmailRequested(VerifyEmailRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await _userAuthRepository.verifyEmail(email: event.email, code: event.code);

    await result.fold(
      (failure) async {
        emit(state.copyWith(
          status: AuthStatus.needsVerification,
          error: failure.message,
        ));
      },
      (data) async {
        final deviceIdEither = await _getDeviceIdUseCase(const NoParams());
        final deviceId = deviceIdEither.getOrElse(() => null);

        final profile = data.profile.copyWith(uuid: deviceId);
        await _userProfileRepository.saveProfile(profile);

        if (!profile.hasAccess) {
          emit(state.copyWith(
            status: AuthStatus.needsSubscription,
            userProfile: profile,
            deviceId: deviceId,
          ));
          return;
        }

        if (deviceId != null) {
          await _approveDeviceUseCase(ApproveDeviceParams(deviceId: deviceId));
        }

        emit(state.copyWith(
          status: AuthStatus.authenticatedDriver,
          userProfile: profile,
          deviceId: deviceId,
          error: null,
        ));
      },
    );
  }

  Future<void> _onResendOtpRequested(ResendOtpRequested event, Emitter<AuthState> emit) async {
    final result = await _userAuthRepository.resendOtp(event.email);
    result.fold(
      (failure) => emit(state.copyWith(error: failure.message)),
      (_) => emit(state.copyWith(message: 'Código de verificación reenviado.')),
    );
  }

  Future<void> _onForgotPasswordRequested(ForgotPasswordRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await _forgotPasswordUseCase(event.email);
    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        error: failure.message,
      )),
      (_) => emit(state.copyWith(
        status: AuthStatus.forgotPasswordOtpSent,
        message: 'Código de recuperación enviado a tu correo.',
        rememberedEmail: event.email,
      )),
    );
  }

  Future<void> _onResetPasswordRequested(ResetPasswordRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await _resetPasswordUseCase(
      ResetPasswordParams(
        email: event.email,
        code: event.code,
        newPassword: event.newPassword,
      ),
    );
    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.forgotPasswordOtpSent,
        error: failure.message,
      )),
      (_) => emit(state.copyWith(
        status: AuthStatus.passwordResetSuccess,
        message: 'Contraseña restablecida correctamente. Inicia sesión.',
      )),
    );
  }

  Future<void> _onStartTrial(StartTrial event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await _startTrialUseCase(const NoParams());
    
    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.needsSubscription,
        error: failure.message,
      )),
      (profile) {
        emit(state.copyWith(
          status: AuthStatus.authenticatedDriver,
          userProfile: profile,
        ));
      },
    );
  }

  Future<void> _onSubscribe(Subscribe event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    
    if (state.userProfile == null) {
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        error: 'Usuario no encontrado',
      ));
      return;
    }

    final result = await _activateSubscriptionUseCase(
      ActivateSubscriptionParams(profile: state.userProfile!),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.needsSubscription,
        error: failure.message,
      )),
      (profile) {
        emit(state.copyWith(
          status: AuthStatus.authenticatedDriver,
          userProfile: profile,
        ));
      },
    );
  }

  Future<void> _onUpdateProfile(UpdateProfile event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await _updateProfileUseCase(
      UpdateProfileParams(
        name: event.name,
        phone: event.phone,
        businessType: event.businessType,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(error: failure.message)),
      (profile) => emit(state.copyWith(
        status: AuthStatus.authenticatedDriver,
        userProfile: profile,
      )),
    );
  }

  Future<void> _onLoginUserRequested(LoginUserRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    
    if (event.rememberMe) {
      await _rememberMeRepository.saveEmail(event.email);
    } else {
      await _rememberMeRepository.clearEmail();
    }

    final result = await _loginUserUseCase(
      LoginUserParams(email: event.email, password: event.password),
    );

    await result.fold(
      (failure) async {
        if (failure.message.contains('verificada')) {
           emit(state.copyWith(
            status: AuthStatus.needsVerification,
            error: null,
            rememberedEmail: event.email
          ));
        } else {
          emit(state.copyWith(
            status: AuthStatus.unauthenticated,
            error: failure.message,
          ));
        }
      },
      (data) async {
        final deviceIdEither = await _getDeviceIdUseCase(const NoParams());
        final deviceId = deviceIdEither.getOrElse(() => null);

        final profile = data.profile.copyWith(uuid: deviceId);
        await _userProfileRepository.saveProfile(profile);

        // Verificamos si el usuario tiene rol administrativo (ej. diego_master)
        final userRole = await _tokenManager.getUserRole();
        if (userRole == 'ADMIN' || userRole == 'SUPER_ADMIN' || userRole == 'SUPERVISOR') {
          AppLogger.i('AuthBloc: Login con rol administrativo ($userRole) detectado. Redirigiendo al panel.');
          emit(state.copyWith(
            status: AuthStatus.authenticatedAdmin,
            userProfile: profile,
            userRole: userRole,
            error: null,
          ));
          return;
        }

        if (!profile.hasAccess) {
          emit(state.copyWith(
            status: AuthStatus.needsSubscription,
            userProfile: profile,
            deviceId: deviceId,
          ));
          return;
        }

        if (deviceId != null) {
          await _approveDeviceUseCase(ApproveDeviceParams(deviceId: deviceId));
        }

        emit(state.copyWith(
          status: AuthStatus.authenticatedDriver,
          userProfile: profile,
          deviceId: deviceId,
          error: null,
        ));
      },
    );
  }

  Future<void> _onGoogleLoginRequested(GoogleLoginRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final googleUser = await _googleAuthService.signIn();
      if (googleUser == null) {
        emit(state.copyWith(status: AuthStatus.unauthenticated));
        return;
      }

      final result = await _userAuthRepository.googleLogin(
        email: googleUser.email,
        name: googleUser.displayName ?? 'Usuario',
        googleId: googleUser.id,
      );

      await result.fold(
        (failure) async => emit(state.copyWith(
          status: AuthStatus.unauthenticated,
          error: failure.message,
        )),
        (data) async {
          final deviceIdEither = await _getDeviceIdUseCase(const NoParams());
          final deviceId = deviceIdEither.getOrElse(() => null);

          final profile = data.profile.copyWith(uuid: deviceId);
          await _userProfileRepository.saveProfile(profile);

          if (!profile.hasAccess) {
            emit(state.copyWith(
              status: AuthStatus.needsSubscription,
              userProfile: profile,
              deviceId: deviceId,
            ));
            return;
          }

          if (deviceId != null) {
            await _approveDeviceUseCase(ApproveDeviceParams(deviceId: deviceId));
          }

          emit(state.copyWith(
            status: AuthStatus.authenticatedDriver,
            userProfile: profile,
            deviceId: deviceId,
            error: null,
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        error: 'Error en la autenticación con Google: ${e.toString()}',
      ));
    }
  }
}
