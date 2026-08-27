import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';

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
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.read<AuthBloc>().add(ClearError());
        }
      },
      child: Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0C081A),
              Color(0xFF1E0E3D),
              Color(0xFF0A0516),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C4DFF).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF7C4DFF).withValues(alpha: 0.25),
                      width: 2.0,
                    ),
                  ),
                  child: const Icon(
                    Icons.payments_rounded,
                    size: 100,
                    color: Color(0xFF00E5FF),
                  ),
                ),
                const SizedBox(height: 36),
                const Text(
                  'SonoPay',
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Detección y gestión inteligente de notificaciones de pago por voz en tiempo real para cualquier rubro comercial.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        context.go('/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C4DFF),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 58),
                        shadowColor: const Color(0xFF7C4DFF).withValues(alpha: 0.4),
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Iniciar Sesión',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: -10,
                      right: 15,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Image.network(
                          'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png',
                          height: 16,
                          width: 18, // Forzamos ancho para evitar que se vea como texto
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                OutlinedButton(
                  onPressed: () {
                    context.go('/register');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
                    minimumSize: const Size(double.infinity, 58),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Crear Cuenta',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  }
}
