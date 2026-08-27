import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/yt_design_system.dart';

class AuthOptionsScreen extends StatelessWidget {
  const AuthOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.primary),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.payments_rounded,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 32),
              Text(
                'Bienvenido a SonoPay',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Gestiona tus pagos de forma rápida y segura. Selecciona una opción para continuar.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              YtButton(
                label: 'Iniciar sesión',
                onPressed: () {
                  context.go('/login');
                },
              ),
              const SizedBox(height: 16),
              YtButton(
                label: 'Ingresar como Dispositivo',
                isSecondary: true,
                onPressed: () {
                  context.go('/pair-device');
                },
              ),
              const SizedBox(height: 16),
              YtButton(
                label: 'Registrarse',
                isSecondary: true,
                onPressed: () {
                  context.go('/register');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
