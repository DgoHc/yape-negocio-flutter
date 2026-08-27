
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecases/usecase.dart';
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
import '../../../../core/utils/app_logger.dart';
import '../../../../core/services/google_auth_service.dart';
import '../../domain/repositories/remember_me_repository.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../../domain/repositories/payment_gateway_repository.dart';
import '../../domain/repositories/user_auth_repository.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/payment_provider.dart';
import '../../domain/entities/auth_status_result.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {
  const AppStarted();
}

class LogoutRequested extends AuthEvent {
  final String? message;
  const LogoutRequested({this.message});

  @override
  List<Object?> get props => [message];
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

class StartTrial extends AuthEvent {
  const StartTrial();
}

class ClearError extends AuthEvent {
  const ClearError();
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
  loading,
  noAccess,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final String? error;
  final String? userRole;
  final String? deviceId;
  final String? rememberedEmail;
  final DateTime? timestamp;
  final UserProfile? userProfile;

  const AuthState({
    this.status = AuthStatus.initial,
    this.error,
    this.userRole,
    this.deviceId,
    this.rememberedEmail,
    this.timestamp,
    this.userProfile,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? error,
    String? userRole,
    String? deviceId,
    String? rememberedEmail,
    DateTime? timestamp,
    UserProfile? userProfile,
  }) {
    return AuthState(
      status: status ?? this.status,
      error: error ?? this.error,
      userRole: userRole ?? this.userRole,
      deviceId: deviceId ?? this.deviceId,
      rememberedEmail: rememberedEmail ?? this.rememberedEmail,
      timestamp: timestamp ?? this.timestamp,
      userProfile: userProfile ?? this.userProfile,
    );
  }

  @override
  List<Object?> get props => [status, error, userRole, deviceId, rememberedEmail, timestamp, userProfile];
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
  final UserProfileRepository _userProfileRepository;
  final PaymentGatewayRepository _paymentGatewayRepository;
  final RememberMeRepository _rememberMeRepository;
  final GoogleAuthService _googleAuthService;
  final UserAuthRepository _userAuthRepository;

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
    this._userProfileRepository,
    this._paymentGatewayRepository,
    this._rememberMeRepository,
    this._googleAuthService,
    this._userAuthRepository,
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
    on<StartTrial>(_onStartTrial);
    on<Subscribe>(_onSubscribe);
    on<UpdateProfile>(_onUpdateProfile);
    on<ClearError>(_onClearError);
  }

  Future<void> _onAdminLoginRequested(AdminLoginRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await _loginAdminUseCase(event.username, event.pin);
    result.fold(
      (failure) => emit(state.copyWith(status: AuthStatus.unauthenticated, error: failure.message)),
      (token) => add(const AppStarted()),
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
      userProfile: result.userProfile,
    );
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
        ));
      },
    );
  }

  Future<void> _onVerifyEmailRequested(VerifyEmailRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await _userAuthRepository.verifyEmail(
      email: event.email,
      code: event.code,
    );

    await result.fold(
      (failure) async => emit(state.copyWith(
        status: AuthStatus.needsVerification,
        error: failure.message,
      )),
      (data) async {
        final deviceIdEither = await _getDeviceIdUseCase(const NoParams());
        final deviceId = deviceIdEither.getOrElse(() => null);
        
        final profile = data.profile.copyWith(uuid: deviceId);
        await _userProfileRepository.saveProfile(profile);

        if (deviceId != null) {
          await _approveDeviceUseCase(ApproveDeviceParams(deviceId: deviceId));
        }

        AuthStatus nextStatus;
        if (profile.businessType == null) {
          nextStatus = AuthStatus.authenticatedDriver;
        } else if (!profile.hasAccess) {
          nextStatus = AuthStatus.needsSubscription;
        } else {
          nextStatus = AuthStatus.authenticatedDriver;
        }

        emit(state.copyWith(
          status: nextStatus,
          userProfile: profile,
          deviceId: deviceId,
        ));
      },
    );
  }

  Future<void> _onResendOtpRequested(ResendOtpRequested event, Emitter<AuthState> emit) async {
    final result = await _userAuthRepository.resendOtp(event.email);
    result.fold(
      (failure) => emit(state.copyWith(error: failure.message)),
      (_) => null,
    );
  }

  Future<void> _onStartTrial(StartTrial event, Emitter<AuthState> emit) async {
    AppLogger.d('AuthBloc: Start trial requested');
    emit(state.copyWith(status: AuthStatus.loading, error: null));
    final result = await _startTrialUseCase(const NoParams());

    await result.fold(
      (failure) async {
        AppLogger.e('AuthBloc: Start trial failed: ${failure.message}');
        emit(state.copyWith(
          status: AuthStatus.needsSubscription,
          error: failure.message,
        ));
      },
      (profile) async {
        AppLogger.d('AuthBloc: Start trial successful');
        final deviceIdEither = await _getDeviceIdUseCase(const NoParams());
        final deviceId = deviceIdEither.getOrElse(() => null);
        
        final updatedProfile = profile.copyWith(uuid: deviceId);
        await _userProfileRepository.saveProfile(updatedProfile);

        if (deviceId != null) {
          await _approveDeviceUseCase(ApproveDeviceParams(deviceId: deviceId));
        }

        emit(state.copyWith(
          status: AuthStatus.authenticatedDriver,
          deviceId: deviceId,
          userProfile: updatedProfile,
        ));
      },
    );
  }

  Future<void> _onSubscribe(Subscribe event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading, error: null));

    if (event.provider != null) {
      final paymentResult = await _paymentGatewayRepository.processPayment(
        provider: event.provider!,
        amount: event.amount,
        currency: 'PEN',
        description: 'Suscripción mensual SonoPay',
      );

      final errorOccurred = await paymentResult.fold(
        (failure) async {
          emit(state.copyWith(
            status: AuthStatus.needsSubscription,
            error: failure.message,
          ));
          return true;
        },
        (success) async {
          if (!success.success) {
            emit(state.copyWith(
              status: AuthStatus.needsSubscription,
              error: success.errorMessage ?? 'El pago no pudo ser procesado',
            ));
            return true;
          }
          return false;
        },
      );
      if (errorOccurred) return;
    }

    UserProfile? profile = state.userProfile;
    final deviceIdEither = await _getDeviceIdUseCase(const NoParams());
    final String? currentDeviceId = deviceIdEither.getOrElse(() => null);

    if (profile == null) {
      profile = UserProfile.createSubscription(
        name: 'Usuario SonoPay',
        uuid: currentDeviceId,
      );
      await _userProfileRepository.saveProfile(profile);
    } else {
      final result = await _activateSubscriptionUseCase(
        ActivateSubscriptionParams(profile: profile),
      );
      
      final errorOccurred = await result.fold(
        (failure) async {
          emit(state.copyWith(
            status: AuthStatus.needsSubscription,
            error: 'Pago exitoso, pero hubo un error al activar la cuenta: ${failure.message}',
          ));
          return true;
        },
        (updatedProfile) async {
          profile = updatedProfile;
          return false;
        },
      );
      if (errorOccurred) return;
    }

    if (currentDeviceId != null) {
      await _approveDeviceUseCase(ApproveDeviceParams(deviceId: currentDeviceId));
    }

    emit(state.copyWith(
      status: AuthStatus.authenticatedDriver,
      deviceId: currentDeviceId,
      userProfile: profile,
      error: null,
    ));
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
        ));
      },
    );
  }

  Future<void> _onGoogleLoginRequested(GoogleLoginRequested event, Emitter<AuthState> emit) async {
    AppLogger.d('AuthBloc: Google login requested');
    emit(state.copyWith(status: AuthStatus.loading));
    
    try {
      final googleUser = await _googleAuthService.signIn();
      
      if (googleUser != null) {
        AppLogger.d('AuthBloc: Google user obtained: ${googleUser.email}');
        
        final name = googleUser.displayName ?? 'Usuario Google';
        final email = googleUser.email;
        final googleId = googleUser.id;
        
        final result = await _userAuthRepository.googleLogin(
          email: email,
          name: name,
          googleId: googleId,
        );

        await result.fold(
          (failure) async {
            AppLogger.e('AuthBloc: Google Login failed: ${failure.message}');
            emit(state.copyWith(
              status: AuthStatus.unauthenticated,
              error: "Error al vincular cuenta de Google: ${failure.message}",
            ));
          },
          (data) async {
            AppLogger.d('AuthBloc: Google Login successful for $email');
            final deviceIdEither = await _getDeviceIdUseCase(const NoParams());
            final deviceId = deviceIdEither.getOrElse(() => null);
            
            final profile = data.profile.copyWith(uuid: deviceId);
            await _userProfileRepository.saveProfile(profile);
            
            if (deviceId != null) {
              AppLogger.d('AuthBloc: Linking device $deviceId');
              await _approveDeviceUseCase(ApproveDeviceParams(deviceId: deviceId));
            }

            AuthStatus nextStatus;
            if (!profile.hasAccess) {
              nextStatus = AuthStatus.needsSubscription;
            } else if (profile.businessType == null) {
              nextStatus = AuthStatus.authenticatedDriver;
            } else {
              nextStatus = AuthStatus.authenticatedDriver;
            }

            emit(state.copyWith(
              status: nextStatus,
              userProfile: profile,
              deviceId: deviceId,
            ));
          },
        );
      } else {
        AppLogger.w('AuthBloc: Google Sign-In cancelled by user or configuration error');
        emit(state.copyWith(status: AuthStatus.unauthenticated));
      }
    } catch (e, stack) {
      AppLogger.e('AuthBloc: Critical error in Google login', e, stack);
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        error: "Error en el inicio de sesión con Google: $e",
      ));
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    final result = await _logoutUseCase(const NoParams());
    final rememberedEmail = state.rememberedEmail;
    result.fold(
      (failure) => emit(AuthState(
        status: AuthStatus.unauthenticated, 
        error: event.message ?? failure.message,
        rememberedEmail: rememberedEmail,
      )),
      (_) => emit(AuthState(
        status: AuthStatus.unauthenticated,
        error: event.message,
        rememberedEmail: rememberedEmail,
      )),
    );
  }

  Future<void> _onUpdateProfile(UpdateProfile event, Emitter<AuthState> emit) async {
    AppLogger.d('AuthBloc: Update profile requested');
    emit(state.copyWith(status: AuthStatus.loading));

    final result = await _updateProfileUseCase(
      UpdateProfileParams(
        name: event.name,
        phone: event.phone,
        businessType: event.businessType,
      ),
    );

    await result.fold(
      (failure) async {
        AppLogger.e('AuthBloc: Update profile failed: ${failure.message}');
        emit(state.copyWith(
          status: AuthStatus.authenticatedDriver,
          error: failure.message,
        ));
      },
      (profile) async {
        AppLogger.d('AuthBloc: Update profile successful');
        await _userProfileRepository.saveProfile(profile);
        
        AuthStatus nextStatus;
        if (!profile.hasAccess) {
          nextStatus = AuthStatus.needsSubscription;
        } else {
          nextStatus = AuthStatus.authenticatedDriver;
        }

        emit(state.copyWith(
          status: nextStatus,
          userProfile: profile,
        ));
      },
    );
  }

  void _onClearError(ClearError event, Emitter<AuthState> emit) {
    emit(state.copyWith(error: null));
  }
}
