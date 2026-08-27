
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
  bool _rememberMe = true;

  @override
  void initState() {
    super.initState();
    final state = context.read<AuthBloc>().state;
    if (state.rememberedEmail != null) {
      _emailController.text = state.rememberedEmail!;
    }
  }

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
          context.go('/notification-onboarding');
        } else if (state.status == AuthStatus.authenticatedAdmin) {
          context.go('/admin-panel');
        } else if (state.status == AuthStatus.needsSubscription) {
          context.go('/subscription');
        } else if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!), backgroundColor: Colors.red),
          );
          context.read<AuthBloc>().add(ClearError());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.primary),
            onPressed: () => context.go('/'),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Icon(
                  Icons.directions_bus_filled_rounded,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 32),
                Text(
                  'Iniciar Sesión',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Ingresa tus credenciales para acceder',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                YtTextField(
                  controller: _emailController,
                  label: 'Correo Electrónico',
                  hintText: 'correo@ejemplo.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 24),
                YtTextField(
                  controller: _passwordController,
                  label: 'Contraseña',
                  hintText: 'Tu contraseña',
                  prefixIcon: Icons.lock_outlined,
                  obscureText: true,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: _rememberMe,
                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value ?? false;
                          });
                        },
                        activeColor: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Recordar mi correo',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 36),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state.status == AuthStatus.loading) {
                      return const Center(child: YtLoader());
                    }
                    return Column(
                      children: [
                        YtButton(
                          label: 'Ingresar',
                          onPressed: () {
                            if (_emailController.text.isNotEmpty &&
                                _passwordController.text.isNotEmpty) {
                              context.read<AuthBloc>().add(
                                    LoginUserRequested(
                                      email: _emailController.text.trim(),
                                      password: _passwordController.text,
                                      rememberMe: _rememberMe,
                                    ),
                                  );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Por favor, ingresa tu correo y contraseña'),
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () {
                            context.read<AuthBloc>().add(const GoogleLoginRequested());
                          },
                          icon: Image.network(
                            'https://upload.wikimedia.org/wikipedia/commons/5/53/Google_%22G%22_Logo.svg',
                            height: 24,
                            errorBuilder: (context, error, stackTrace) => 
                              const Icon(Icons.login),
                          ),
                          label: const Text('Continuar con Google'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            side: const BorderSide(color: Colors.grey),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    context.go('/admin-login');
                  },
                  child: const Text(
                    'Soy Administrador',
                    style: TextStyle(color: AppTheme.primaryColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

