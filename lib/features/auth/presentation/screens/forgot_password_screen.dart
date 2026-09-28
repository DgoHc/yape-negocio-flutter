import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/yt_design_system.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/auth_bloc.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  int _step = 1; // 1: Pedir email, 2: Pedir OTP y nueva contraseña

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.forgotPasswordOtpSent) {
          setState(() {
            _step = 2;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message ?? 'Código de recuperación enviado.'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          context.read<AuthBloc>().add(const ClearError());
        } else if (state.status == AuthStatus.passwordResetSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message ?? 'Contraseña restablecida con éxito. Inicia sesión.'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          context.read<AuthBloc>().add(const ResetAuthStatus());
          context.go('/login');
        } else if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: AppTheme.errorColor,
            ),
          );
          context.read<AuthBloc>().add(const ClearError());
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppTheme.backgroundColor,
        body: Stack(
          children: [
            const BrandBlobHeader(height: 260, child: SizedBox.shrink()),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 70),
                      Text(
                        _step == 1 ? '¿Olvidaste tu contraseña?' : 'Nueva Contraseña',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _step == 1
                            ? 'Ingresa tu correo para recibir un código de verificación.'
                            : 'Ingresa el código enviado a tu correo y tu nueva contraseña.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 40),
                      if (_step == 1) ...[
                        YtTextField(
                          controller: _emailController,
                          label: 'Correo Electrónico',
                          hintText: 'tu@correo.com',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) =>
                              value == null || value.trim().isEmpty ? 'Campo requerido' : null,
                        ),
                        const SizedBox(height: 40),
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            return AppButton(
                              label: 'Enviar Código',
                              isLoading: state.status == AuthStatus.loading,
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  context.read<AuthBloc>().add(
                                        ForgotPasswordRequested(_emailController.text.trim()),
                                      );
                                }
                              },
                            );
                          },
                        ),
                      ] else ...[
                        YtTextField(
                          controller: _codeController,
                          label: 'Código de Verificación (6 dígitos)',
                          hintText: '000000',
                          prefixIcon: Icons.pin_outlined,
                          keyboardType: TextInputType.number,
                          validator: (value) =>
                              value == null || value.trim().length != 6 ? 'Código debe ser de 6 dígitos' : null,
                        ),
                        const SizedBox(height: 20),
                        YtTextField(
                          controller: _newPasswordController,
                          label: 'Nueva Contraseña',
                          hintText: 'Mínimo 6 caracteres',
                          prefixIcon: Icons.lock_outline,
                          obscureText: true,
                          validator: (value) =>
                              value == null || value.length < 6 ? 'Mínimo 6 caracteres' : null,
                        ),
                        const SizedBox(height: 20),
                        YtTextField(
                          controller: _confirmPasswordController,
                          label: 'Confirmar Nueva Contraseña',
                          hintText: 'Repite tu contraseña',
                          prefixIcon: Icons.lock_reset_outlined,
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Campo requerido';
                            if (value != _newPasswordController.text) return 'Las contraseñas no coinciden';
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            return AppButton(
                              label: 'Restablecer Contraseña',
                              isLoading: state.status == AuthStatus.loading,
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  context.read<AuthBloc>().add(
                                        ResetPasswordRequested(
                                          email: _emailController.text.trim(),
                                          code: _codeController.text.trim(),
                                          newPassword: _newPasswordController.text,
                                        ),
                                      );
                                }
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              context.read<AuthBloc>().add(
                                    ForgotPasswordRequested(_emailController.text.trim()),
                                  );
                            },
                            child: const Text('Reenviar código OTP'),
                          ),
                        ),
                      ],
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('¿Recordaste tu contraseña?'),
                          TextButton(
                            onPressed: () {
                              context.read<AuthBloc>().add(const ResetAuthStatus());
                              context.go('/login');
                            },
                            child: const Text('Inicia Sesión', style: TextStyle(fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
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
                  onPressed: () {
                    if (_step == 2) {
                      setState(() {
                        _step = 1;
                      });
                    } else {
                      context.read<AuthBloc>().add(const ResetAuthStatus());
                      context.go('/login');
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
