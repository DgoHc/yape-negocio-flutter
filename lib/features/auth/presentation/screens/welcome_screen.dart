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
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!), backgroundColor: AppTheme.errorColor, behavior: SnackBarBehavior.floating));
          context.read<AuthBloc>().add(const ClearError());
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Stack(
          children: [
            const BrandBlobHeader(height: 380, child: SizedBox.shrink()),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(22),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 10))]),
                        child: const Icon(Icons.payments_rounded, size: 75, color: AppTheme.primaryColor),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text('SonoPay', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                    const Spacer(),
                    Text('Detección inteligente de pagos por voz en tiempo real.', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary, fontSize: 18, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    Text('La herramienta definitiva para comerciantes y transportistas.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textPlaceholder), textAlign: TextAlign.center),
                    const SizedBox(height: 48),
                    BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
                      final isLoading = state.status == AuthStatus.loading;
                      return Column(children: [
                        AppButton(label: 'Iniciar Sesión', onPressed: isLoading ? null : () => context.go('/login')),
                        const SizedBox(height: 18),
                        AppButton(label: 'Continuar con Google', isSecondary: true, isLoading: isLoading, onPressed: isLoading ? null : () => context.read<AuthBloc>().add(const GoogleLoginRequested()), prefixWidget: isLoading ? null : Image.network('https://www.gstatic.com/images/branding/product/1x/googleg_32dp.png', height: 20, width: 20)),
                      ]);
                    }),
                    const SizedBox(height: 32),
                    TextButton(onPressed: () => context.go('/register'), child: Text('Crear una cuenta nueva', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, decoration: TextDecoration.underline))),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
