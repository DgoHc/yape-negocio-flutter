import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/auth/presentation/screens/auth_options_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/auth/presentation/screens/admin_login_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/user_registration_screen.dart';
import '../../features/auth/presentation/screens/subscription_screen.dart';
import '../../features/auth/presentation/screens/setup_business_type_screen.dart';
import '../../features/auth/presentation/screens/email_verification_screen.dart';
import '../../features/admin/presentation/screens/admin_panel_screen.dart';
import '../../features/notifications/presentation/screens/notification_onboarding_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../di/injection_container.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStream(sl<AuthBloc>().stream),
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/auth-options',
        builder: (context, state) => const AuthOptionsScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/admin-panel',
        builder: (context, state) => const AdminPanelScreen(),
      ),
      GoRoute(
        path: '/admin-login',
        builder: (context, state) => const AdminLoginScreen(),
      ),
      GoRoute(
        path: '/notification-onboarding',
        builder: (context, state) => const NotificationOnboardingScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const UserRegistrationScreen(),
      ),
      GoRoute(
        path: '/subscription',
        builder: (context, state) => const SubscriptionScreen(),
      ),
      GoRoute(
        path: '/setup-business-type',
        builder: (context, state) => const SetupBusinessTypeScreen(),
      ),
      GoRoute(
        path: '/verify-email',
        builder: (context, state) => const EmailVerificationScreen(),
      ),
    ],
    redirect: (context, state) {
      final authState = context.read<AuthBloc>().state;
      final location = state.matchedLocation;
      
      final isSplashing = location == '/splash';
      final isWelcome = location == '/';
      final isOptions = location == '/auth-options';
      final isLogin = location == '/login';
      final isAdminLogin = location == '/admin-login';
      final isRegister = location == '/register';
      final isSubscription = location == '/subscription';
      final isSetupBusinessType = location == '/setup-business-type';
      final isVerifyEmail = location == '/verify-email';
      
      if (isSplashing) return null;

      // 0. Public Routes
      if (isLogin || isAdminLogin || isRegister || isVerifyEmail || isSetupBusinessType || isSubscription) {
        if (authState.status == AuthStatus.authenticatedAdmin) return '/admin-panel';
        if (authState.status == AuthStatus.authenticatedDriver) {
          if (authState.userProfile?.businessType == null) {
            return isSetupBusinessType ? null : '/setup-business-type';
          }
          // Permitir acceso a la pantalla de suscripción incluso si está autenticado (para ver planes o renovar)
          if (isSubscription) return null;
          return '/notification-onboarding';
        }
        
        if (authState.status == AuthStatus.needsVerification && !isVerifyEmail) {
          return '/verify-email';
        }

        return null; 
      }

      // 1. Auth states logic
      switch (authState.status) {
        case AuthStatus.initial:
          return isWelcome || isOptions || isLogin || isRegister ? null : '/';
          
        case AuthStatus.needsVerification:
          return isVerifyEmail ? null : '/verify-email';

        case AuthStatus.noAccess:
        case AuthStatus.needsSubscription:
          // Permitir ir atrás al welcome o opciones si está en este estado
          if (isWelcome || isOptions || isSubscription) return null;
          return '/subscription';
          
        case AuthStatus.needsRegistration:
          return isRegister ? null : '/register';
          
        case AuthStatus.unauthenticated:
          return isWelcome || isOptions || isLogin || isAdminLogin ? null : '/';
          
        case AuthStatus.authenticatedAdmin:
          // Solo forzar redirect si intenta acceder a rutas de login/registro o dashboard de driver
          if (isLogin || isAdminLogin || isRegister || location == '/dashboard') return '/admin-panel';
          return null;
          
        case AuthStatus.authenticatedDriver:
          if (authState.userProfile?.businessType == null) {
            return '/setup-business-type';
          }
          // Si intenta ir a login/registro siendo ya driver, mandarlo al onboarding
          if (isLogin || isAdminLogin || isRegister) {
            return '/notification-onboarding';
          }
          return null;

        case AuthStatus.loading:
          return null;
      }
    },
  );
}
