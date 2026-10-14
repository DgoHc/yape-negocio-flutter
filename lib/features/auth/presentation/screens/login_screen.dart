import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/yt_design_system.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/auth_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticatedDriver) {
          context.go('/dashboard');
        } else if (state.status == AuthStatus.authenticatedAdmin) {
          context.go('/admin-panel');
        } else if (state.status == AuthStatus.needsSubscription) {
          context.go('/subscription');
        } else if (state.status == AuthStatus.needsVerification) {
          context.go('/verify-email');
        } else if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!), backgroundColor: AppTheme.errorColor),
          );
          context.read<AuthBloc>().add(const ClearError());
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppTheme.backgroundColor,
        body: Stack(
          children: [
            const BrandBlobHeader(height: 280, child: SizedBox.shrink()),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 40),
                              Text('¡Hola de nuevo!', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
                              const SizedBox(height: 6),
                              Text('Ingresa a tu cuenta SonoPay', style: Theme.of(context).textTheme.bodyMedium),
                              const SizedBox(height: 36),
                              YtTextField(
                                controller: _emailController,
                                label: 'Correo Electrónico',
                                hintText: 'tu@correo.com',
                                prefixIcon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
                              ),
                              const SizedBox(height: 18),
                              YtTextField(
                                controller: _passwordController,
                                label: 'Contraseña',
                                hintText: '••••••••',
                                prefixIcon: Icons.lock_outline,
                                obscureText: true,
                                validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () => context.push('/forgot-password'),
                                  child: const Text('¿Olvidaste tu contraseña?', style: TextStyle(fontSize: 13)),
                                ),
                              ),
                              const SizedBox(height: 24),
                              BlocBuilder<AuthBloc, AuthState>(
                                builder: (context, state) => AppButton(
                                  label: 'Ingresar',
                                  isLoading: state.status == AuthStatus.loading,
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      context.read<AuthBloc>().add(
                                            LoginUserRequested(
                                              email: _emailController.text.trim(),
                                              password: _passwordController.text,
                                            ),
                                          );
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(height: 28),
                              Row(
                                children: [
                                  const Expanded(child: Divider()),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text('o ingresar con', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                                  ),
                                  const Expanded(child: Divider()),
                                ],
                              ),
                              const SizedBox(height: 20),
                              AppButton(
                                label: 'Google',
                                isSecondary: true,
                                onPressed: () => context.read<AuthBloc>().add(const GoogleLoginRequested()),
                                prefixWidget: Image.network(
                                  'https://www.gstatic.com/images/branding/product/1x/googleg_32dp.png',
                                  height: 20,
                                  width: 20,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata_rounded, size: 24),
                                ),
                              ),
                              const Spacer(),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('¿No tienes cuenta?'),
                                    TextButton(
                                      onPressed: () => context.go('/register'),
                                      child: const Text('Regístrate', style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // BOTÓN REGRESAR MANUAL
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 10,
              child: Material(
                color: Colors.transparent,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary, size: 24),
                  onPressed: () => context.go('/'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
