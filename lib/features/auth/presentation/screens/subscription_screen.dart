
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/yt_design_system.dart';
import '../bloc/auth_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/payment_provider.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Elige tu plan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listenWhen: (previous, current) => 
            (previous.status == AuthStatus.loading && current.status == AuthStatus.authenticatedDriver) ||
            (current.error != null && previous.error != current.error),
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state.status == AuthStatus.authenticatedDriver && state.userProfile?.hasAccess == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('¡Plan activado con éxito!'),
                backgroundColor: Colors.green,
              ),
            );
            context.go('/notification-onboarding');
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                const Text(
                  '¡Bienvenido!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Elige el plan que mejor se adapte a tu negocio',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final profile = state.userProfile;
                    if (profile != null && !profile.hasAccess && profile.trialEndDate != null) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          'Tu periodo de prueba terminó el ${profile.trialEndDate!.day}/${profile.trialEndDate!.month}. Suscríbete para continuar.',
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: 32),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final profile = state.userProfile;
                    final hasUsedTrial = profile?.trialEndDate != null || profile?.isSubscribed == true;

                    return Column(
                      children: [
                        if (!hasUsedTrial) ...[
                          const _TrialCard(),
                          const SizedBox(height: 24),
                        ],
                        const _SubscriptionCard(
                          title: 'Plan Básico',
                          price: '5.00',
                          benefits: [
                            'Todo lo de la prueba gratuita',
                            'Hasta 4 usuarios a notificar',
                            'Acceso ilimitado sin expiración',
                            'Soporte estándar',
                          ],
                          isRecommended: true,
                        ),
                        const SizedBox(height: 24),
                        const _SubscriptionCard(
                          title: 'Plan Premium',
                          price: '10.00',
                          benefits: [
                            'Todo lo del Plan Básico',
                            'Usuarios ilimitados a notificar',
                            'Soporte prioritario 24/7',
                            'Reportes detallados mensuales',
                          ],
                          cardColor: Color(0xFF1A237E), // Un azul más oscuro/premium
                        ),
                        const SizedBox(height: 40),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TrialCard extends StatelessWidget {
  const _TrialCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return YtCard(
          child: Column(
            children: [
              const Icon(
                Icons.timer_outlined,
                size: 48,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 16),
              const Text(
                'Prueba Gratuita',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '14 días',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              const _BenefitsList(
                benefits: [
                  'Detección de pagos en tiempo real',
                  'Registro de todas las transacciones',
                  'Notificaciones de voz',
                  'Exportación de datos',
                ],
              ),
              const SizedBox(height: 24),
              YtButton(
                label: 'Empezar prueba',
                isSecondary: true,
                onPressed: state.status == AuthStatus.loading
                    ? null
                    : () {
                        context.read<AuthBloc>().add(StartTrial());
                      },
                isLoading: state.status == AuthStatus.loading,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  final String title;
  final String price;
  final List<String> benefits;
  final bool isRecommended;
  final Color? cardColor;

  const _SubscriptionCard({
    required this.title,
    required this.price,
    required this.benefits,
    this.isRecommended = false,
    this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: cardColor ?? AppTheme.primaryColor,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                if (isRecommended)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'Recomendado',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                Icon(
                  title.contains('Premium') ? Icons.stars : Icons.workspace_premium_outlined,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    const Text(
                      'S/',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      price,
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      '/mes',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _BenefitsList(
                  benefits: benefits,
                  textColor: Colors.white,
                  iconColor: Colors.white70,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: state.status == AuthStatus.loading
                      ? null
                      : () => _showPaymentMethodDialog(context, double.parse(price)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: cardColor ?? AppTheme.primaryColor,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: state.status == AuthStatus.loading
                      ? const YtLoader()
                      : const Text('Suscribirme ahora'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPaymentMethodDialog(BuildContext context, double amount) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Selecciona método de pago'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.credit_card),
              title: const Text('Tarjeta (Culqi)'),
              onTap: () {
                Navigator.pop(dialogContext);
                context.read<AuthBloc>().add(Subscribe(
                      provider: PaymentProvider.culqi,
                      amount: amount,
                    ));
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Mercado Pago'),
              onTap: () {
                Navigator.pop(dialogContext);
                context.read<AuthBloc>().add(Subscribe(
                      provider: PaymentProvider.mercadoPago,
                      amount: amount,
                    ));
              },
            ),
            ListTile(
              leading: const Icon(Icons.payment),
              title: const Text('Yape'),
              onTap: () {
                Navigator.pop(dialogContext);
                context.read<AuthBloc>().add(Subscribe(
                      provider: PaymentProvider.yape,
                      amount: amount,
                    ));
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }
}

class _BenefitsList extends StatelessWidget {
  final List<String> benefits;
  final Color textColor;
  final Color iconColor;

  const _BenefitsList({
    required this.benefits,
    this.textColor = Colors.black87,
    this.iconColor = Colors.green,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: benefits
          .map(
            (benefit) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: iconColor, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      benefit,
                      style: TextStyle(color: textColor),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
