import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';

import '../../../../core/widgets/yt_design_system.dart';
import '../../../../core/theme/app_theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: AppTheme.errorColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.read<AuthBloc>().add(ClearError());
        }
      },
      child: Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              ClayContainer(
                color: AppTheme.primaryColor,
                borderRadius: 100,
                padding: const EdgeInsets.all(32),
                child: const Icon(
                  Icons.payments_rounded,
                  size: 80,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 48),
              Text(
                'SonoPay',
                style: Theme.of(context).textTheme.displayLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Detección y gestión inteligente de pagos por voz en tiempo real para tu negocio.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  YtButton(
                    label: 'Iniciar Sesión',
                    onPressed: () => context.go('/login'),
                  ),
                  Positioned(
                    top: -10,
                    right: 15,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: Image.network(
                          'https://www.gstatic.com/images/branding/product/1x/googleg_32dp.png',
                          height: 20,
                          width: 20,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              YtButton(
                label: 'Crear Cuenta',
                isSecondary: true,
                onPressed: () => context.go('/register'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    ),
  );
  }
}
  }
}
