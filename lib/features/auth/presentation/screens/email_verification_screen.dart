import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/yt_design_system.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/auth_bloc.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});
  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _codeController = TextEditingController();

  @override
  void dispose() { _codeController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final email = context.watch<AuthBloc>().state.rememberedEmail ?? 'tu correo';
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.authenticatedDriver) context.go('/dashboard');
          else if (state.status == AuthStatus.needsSubscription) context.go('/subscription');
          else if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!), backgroundColor: AppTheme.errorColor));
            context.read<AuthBloc>().add(const ClearError());
          }
        },
        child: Stack(
          children: [
            // Capa de Contenido
            Column(
              children: [
                BrandBlobHeader(
                  height: 300,
                  isDashboard: true,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 60),
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 10))]),
                          child: const Icon(Icons.mark_email_read_rounded, size: 60, color: AppTheme.primaryColor),
                        ),
                        const SizedBox(height: 16),
                        Text('Verificación', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Text('Hemos enviado un código a:', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 8),
                        Text(email, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary, fontSize: 16)),
                        const SizedBox(height: 48),
                        YtTextField(
                          controller: _codeController,
                          label: 'Código de 6 dígitos',
                          hintText: '000000',
                          prefixIcon: Icons.vpn_key_outlined,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 40),
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) => AppButton(
                            label: 'Confirmar Registro',
                            isLoading: state.status == AuthStatus.loading,
                            onPressed: () {
                              if (_codeController.text.length == 6) {
                                context.read<AuthBloc>().add(VerifyEmailRequested(email: email, code: _codeController.text));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingresa los 6 dígitos completos')));
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('¿No recibiste nada?', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                            TextButton(
                              onPressed: () {
                                context.read<AuthBloc>().add(ResendOtpRequested(email));
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Código reenviado')));
                              },
                              child: Text('Reenviar ahora', style: TextStyle(fontWeight: FontWeight.w900, color: AppTheme.primaryColor, fontSize: 13)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 10, 
              left: 10,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () {
                    context.read<AuthBloc>().add(const ResetAuthStatus());
                    context.go('/register');
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 24),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
