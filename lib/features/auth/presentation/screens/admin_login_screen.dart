import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/yt_design_system.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/auth_bloc.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _usernameController = TextEditingController();
  final _pinController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticatedAdmin) {
          context.go('/admin-panel');
        }
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!), backgroundColor: AppTheme.errorColor),
          );
          context.read<AuthBloc>().add(const ClearError());
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Stack(
          children: [
            Column(
              children: [
                BrandBlobHeader(
                  height: 250,
                  isDashboard: true,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      const Icon(Icons.admin_panel_settings_rounded, size: 64, color: Colors.white),
                      const SizedBox(height: 12),
                      Text(
                        'Panel de Control', 
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900, 
                          color: Colors.white
                        )
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),
                      YtTextField(
                        controller: _usernameController, 
                        label: 'Usuario Administrador', 
                        hintText: 'Nombre de usuario', 
                        prefixIcon: Icons.security_outlined
                      ),
                      const SizedBox(height: 24),
                      YtTextField(
                        controller: _pinController, 
                        label: 'PIN Maestro', 
                        hintText: '••••••••', 
                        prefixIcon: Icons.key_outlined, 
                        obscureText: true, 
                        keyboardType: TextInputType.number
                      ),
                      const SizedBox(height: 48),
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          return AppButton(
                            label: 'Verificar Identidad', 
                            isLoading: state.status == AuthStatus.loading, 
                            onPressed: () {
                              if (_usernameController.text.isNotEmpty && _pinController.text.isNotEmpty) {
                                context.read<AuthBloc>().add(
                                      AdminLoginRequested(
                                        username: _usernameController.text,
                                        pin: _pinController.text,
                                      ),
                                    );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Ingresa todas las credenciales')),
                                );
                              }
                            }
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // BOTÓN REGRESAR MANUAL - Siempre al frente
            Positioned(
              top: MediaQuery.of(context).padding.top + 10, 
              left: 10,
              child: Material(
                color: Colors.transparent,
                child: IconButton(
                  padding: const EdgeInsets.all(12),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 24),
                  onPressed: () => context.go('/login'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
