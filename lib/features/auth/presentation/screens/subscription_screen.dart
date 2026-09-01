
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
                backgroundColor: AppTheme.errorColor,
              ),
            );
          } else if (state.status == AuthStatus.authenticatedDriver && state.userProfile?.hasAccess == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('¡Plan activado con éxito!'),
                backgroundColor: AppTheme.successColor,
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
                Text(
                  '¡Bienvenido!',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Elige el plan que mejor se adapte a tu negocio',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
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
                          style: const TextStyle(color: AppTheme.errorColor, fontWeight: FontWeight.bold),
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
                          const SizedBox(height: 32),
                        ],
                        const _SubscriptionCard(
                          title: 'Plan Básico',
                          price: '5.00',
                          benefits: [
                            'Anuncios por voz ilimitados',
                            'Hasta 4 usuarios vinculados',
                            'Acceso vitalicio',
                            'Soporte estándar',
                          ],
                          isRecommended: true,
                        ),
                        const SizedBox(height: 32),
                        const _SubscriptionCard(
                          title: 'Plan Premium',
                          price: '10.00',
                          benefits: [
                            'Todo lo del Plan Básico',
                            'Usuarios ilimitados',
                            'Soporte prioritario 24/7',
                            'Reportes Excel avanzados',
                          ],
                          color: Color(0xFFFFD54F), // Amarillo más brillante
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
          color: AppTheme.surfaceColor,
          child: Column(
            children: [
              const ClayContainer(
                color: AppTheme.secondaryColor,
                borderRadius: 100,
                padding: EdgeInsets.all(16),
                child: Icon(Icons.timer_outlined, size: 32, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 16),
              const Text('Prueba Gratuita', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              const SizedBox(height: 8),
              const Text('14 días', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
              const SizedBox(height: 24),
              const _BenefitsList(benefits: ['Detección en tiempo real', 'Notificaciones de voz', 'Historial seguro']),
              const SizedBox(height: 24),
              YtButton(
                label: 'Empezar prueba',
                isSecondary: true,
                onPressed: state.status == AuthStatus.loading ? null : () => context.read<AuthBloc>().add(StartTrial()),
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
  final Color? color;

  const _SubscriptionCard({
    required this.title,
    required this.price,
    required this.benefits,
    this.isRecommended = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return YtCard(
      color: color ?? AppTheme.primaryColor,
      child: Column(
        children: [
          if (isRecommended)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(16)),
              child: const Text('Recomendado', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text('S/', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              Text(price, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
              const Text('/mes', style: TextStyle(fontSize: 16, color: AppTheme.textSecondary)),
            ],
          ),
          const SizedBox(height: 24),
          _BenefitsList(benefits: benefits),
          const SizedBox(height: 24),
          YtButton(
            label: 'Suscribirme',
            color: AppTheme.surfaceColor,
            onPressed: () => _showPaymentMethodDialog(context, double.parse(price)),
          ),
        ],
      ),
    );
  }

  void _showPaymentMethodDialog(BuildContext context, double amount) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Método de pago', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _MethodTile(icon: Icons.credit_card, label: 'Tarjeta (Culqi)', onTap: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(Subscribe(provider: PaymentProvider.culqi, amount: amount));
            }),
            const SizedBox(height: 12),
            _MethodTile(icon: Icons.shopping_cart, label: 'Mercado Pago', onTap: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(Subscribe(provider: PaymentProvider.mercadoPago, amount: amount));
            }),
          ],
        ),
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MethodTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClayContainer(
      color: AppTheme.surfaceColor,
      borderRadius: 16,
      child: ListTile(
        leading: Icon(icon, color: AppTheme.textPrimary),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        onTap: onTap,
      ),
    );
  }
}

class _BenefitsList extends StatelessWidget {
  final List<String> benefits;
  const _BenefitsList({required this.benefits});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: benefits.map((benefit) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: AppTheme.textSecondary, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(benefit, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14))),
          ],
        ),
      )).toList(),
    );
  }
}
