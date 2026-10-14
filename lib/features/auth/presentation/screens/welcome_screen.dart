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
        if (state.status == AuthStatus.authenticatedDriver) {
          context.go('/dashboard');
        } else if (state.status == AuthStatus.needsSubscription) {
          context.go('/subscription');
        } else if (state.status == AuthStatus.needsVerification) {
          context.go('/verify-email');
        } else if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: AppTheme.errorColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.read<AuthBloc>().add(const ClearError());
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Stack(
          children: [
            const BrandBlobHeader(height: 380, child: SizedBox.shrink()),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            const SizedBox(height: 32),
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 25,
                                      offset: Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.payments_rounded, size: 70, color: AppTheme.primaryColor),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'SonoPay',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontSize: 44,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.2,
                                  ),
                            ),
                            const Spacer(),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                'Detección inteligente de pagos por voz en tiempo real.',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: AppTheme.textSecondary,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      height: 1.3,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'La herramienta definitiva para comerciantes y transportistas.',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppTheme.textPlaceholder,
                                      height: 1.4,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 32),
                            BlocBuilder<AuthBloc, AuthState>(
                              builder: (context, state) {
                                final isLoading = state.status == AuthStatus.loading;
                                return Column(
                                  children: [
                                    AppButton(
                                      label: 'Iniciar Sesión',
                                      onPressed: isLoading ? null : () => context.go('/login'),
                                    ),
                                    const SizedBox(height: 14),
                                    AppButton(
                                      label: 'Continuar con Google',
                                      isSecondary: true,
                                      isLoading: isLoading,
                                      onPressed: isLoading ? null : () => context.read<AuthBloc>().add(const GoogleLoginRequested()),
                                      prefixWidget: isLoading
                                          ? null
                                          : Image.network(
                                              'https://www.gstatic.com/images/branding/product/1x/googleg_32dp.png',
                                              height: 20,
                                              width: 20,
                                              errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata_rounded, size: 24),
                                            ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                            TextButton(
                              onPressed: () => context.go('/register'),
                              child: const Text(
                                'Crear una cuenta nueva',
                                style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
