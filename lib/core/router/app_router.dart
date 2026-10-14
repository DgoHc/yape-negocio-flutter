import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/admin/presentation/screens/admin_panel_screen.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/screens/admin_login_screen.dart';
import '../../features/auth/presentation/screens/auth_options_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/setup_business_type_screen.dart';
import '../../features/auth/presentation/screens/user_registration_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/subscription_screen.dart';
import '../../features/auth/presentation/screens/email_verification_screen.dart';
import '../../features/auth/presentation/screens/onboarding_tutorial_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/notifications/presentation/screens/notification_onboarding_screen.dart';
import '../../features/notifications/presentation/screens/linked_users_screen.dart';
import '../../features/payments/presentation/screens/payment_history_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
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
        path: '/admin-login',
        builder: (context, state) => const AdminLoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const UserRegistrationScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/notification-onboarding',
        builder: (context, state) => const NotificationOnboardingScreen(),
      ),
      GoRoute(
        path: '/linked-users',
        builder: (context, state) => const LinkedUsersScreen(),
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
        path: '/setup-business-type',
        builder: (context, state) => const SetupBusinessTypeScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/subscription',
        builder: (context, state) => const SubscriptionScreen(),
      ),
      GoRoute(
        path: '/verify-email',
        builder: (context, state) => const EmailVerificationScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingTutorialScreen(),
      ),
      GoRoute(
        path: '/payment-history',
        builder: (context, state) => const PaymentHistoryScreen(),
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
      final isForgotPassword = location == '/forgot-password';
      final isOnboarding = location == '/onboarding';
      
      if (isSplashing || isOnboarding) return null;

      // 0. Public Routes
      if (isLogin || isAdminLogin || isRegister || isVerifyEmail || isSetupBusinessType || isSubscription || isForgotPassword) {
        if (authState.status == AuthStatus.authenticatedAdmin) return '/admin-panel';
        if (authState.status == AuthStatus.authenticatedDriver) {
          if (authState.userProfile?.businessType == null) {
            return isSetupBusinessType ? null : '/setup-business-type';
          }
          if (isSubscription || isLogin || isRegister || isWelcome) {
            return '/dashboard';
          }
          return null;
        }
        
        if (authState.status == AuthStatus.needsVerification && !isVerifyEmail && !isRegister) {
          return '/verify-email';
        }

        return null; 
      }

      // 1. Auth states logic
      switch (authState.status) {
        case AuthStatus.initial:
          return isWelcome || isOptions || isLogin || isRegister || isAdminLogin || isForgotPassword ? null : '/';
          
        case AuthStatus.needsVerification:
          return isVerifyEmail || isRegister ? null : '/verify-email';

        case AuthStatus.forgotPasswordOtpSent:
        case AuthStatus.passwordResetSuccess:
          return isForgotPassword || isLogin ? null : '/forgot-password';

        case AuthStatus.noAccess:
        case AuthStatus.needsSubscription:
          if (isWelcome || isOptions || isSubscription || isLogin || isRegister) return null;
          return '/subscription';
          
        case AuthStatus.needsRegistration:
          return isRegister ? null : '/register';

        case AuthStatus.unauthenticated:
          return isWelcome || isOptions || isLogin || isRegister || isAdminLogin || isForgotPassword ? null : '/';
          
        case AuthStatus.authenticatedAdmin:
          return location == '/admin-panel' ? null : '/admin-panel';

        case AuthStatus.authenticatedDriver:
          if (authState.userProfile?.businessType == null) {
            return isSetupBusinessType ? null : '/setup-business-type';
          }
          if (location == '/dashboard' || location == '/settings' || location == '/payment-history' || location == '/notification-onboarding' || location == '/linked-users') {
            return null;
          }
          return '/dashboard';

        case AuthStatus.needsPairing:
          return isLogin || isRegister ? null : '/login';

        case AuthStatus.loading:
          return null;
      }
    },
  );
}
