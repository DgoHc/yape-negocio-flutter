import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';
import '../../../../core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == AuthStatus.loading) return;

        // The AppRouter redirect logic will handle most of this,
        // but we can trigger a refresh here.
        switch (state.status) {
          case AuthStatus.authenticatedAdmin:
            context.go('/admin-panel');
            break;
          case AuthStatus.authenticatedDriver:
            context.go('/notification-onboarding');
            break;
          case AuthStatus.needsRegistration:
            context.go('/register');
            break;
          case AuthStatus.noAccess:
          case AuthStatus.needsSubscription:
            context.go('/subscription');
            break;
          case AuthStatus.unauthenticated:
          case AuthStatus.initial:
            context.go('/');
            break;
          default:
            break;
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.primaryColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.directions_bus,
                size: 100,
                color: Colors.white,
              ),
              const SizedBox(height: 24),
              const Text(
                'YAPE TRANSPORTE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
