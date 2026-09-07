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
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Elige tu plan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!), backgroundColor: AppTheme.errorColor));
          } else if (state.status == AuthStatus.authenticatedDriver && state.userProfile?.hasAccess == true) {
            context.go('/dashboard');
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              BrandBlobHeader(
                height: 180,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.auto_awesome_rounded, size: 50, color: AppTheme.primaryColor),
                    const SizedBox(height: 12),
                    Text('Potencia tu Negocio', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text('Elige la opción que mejor se adapte a tu ritmo de trabajo.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 32),
              const _PlanCard(
                title: 'Prueba Gratuita',
                price: '0.00',
                duration: '14 días',
                isTrial: true,
                features: ['Anuncios por voz', 'Historial básico', '1 Dispositivo'],
              ),
              const SizedBox(height: 24),
              const _PlanCard(
                title: 'Plan Profesional',
                price: '5.00',
                duration: 'mensual',
                isRecommended: true,
                features: ['Anuncios ilimitados', 'Reportes Excel', 'Múltiples socios', 'Soporte 24/7'],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String duration;
  final List<String> features;
  final bool isRecommended;
  final bool isTrial;

  const _PlanCard({required this.title, required this.price, required this.duration, required this.features, this.isRecommended = false, this.isTrial = false});

  @override
  Widget build(BuildContext context) {
    return ClayContainer(
      color: isRecommended ? AppTheme.primaryColor : Colors.white,
      borderRadius: 28,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          if (isRecommended)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(12)),
              child: const Text('RECOMENDADO', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Color(0xFF3D2E00))),
            ),
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isRecommended ? const Color(0xFF3D2E00) : AppTheme.textPrimary)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('S/', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isRecommended ? const Color(0xFF3D2E00) : AppTheme.textSecondary)),
              Text(price, style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: isRecommended ? const Color(0xFF3D2E00) : AppTheme.textPrimary)),
              Text('/$duration', style: TextStyle(fontSize: 14, color: isRecommended ? const Color(0xFF3D2E00).withValues(alpha: 0.6) : AppTheme.textSecondary)),
            ],
          ),
          const Divider(height: 32, thickness: 0.5),
          ...features.map((f) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(children: [
              Icon(Icons.check_circle_rounded, size: 16, color: isRecommended ? const Color(0xFF3D2E00) : AppTheme.successColor),
              const SizedBox(width: 8),
              Text(f, style: TextStyle(fontSize: 13, color: isRecommended ? const Color(0xFF3D2E00) : AppTheme.textPrimary)),
            ]),
          )),
          const SizedBox(height: 24),
          AppButton(
            label: isTrial ? 'Empezar Prueba' : 'Adquirir Plan',
            color: isRecommended ? Colors.white : AppTheme.primaryColor,
            onPressed: () {
              if (isTrial) {
                context.read<AuthBloc>().add(const StartTrial());
              } else {
                _showPaymentMethods(context, double.parse(price));
              }
            },
          ),
        ],
      ),
    );
  }

  void _showPaymentMethods(BuildContext context, double amount) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.backgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Selecciona tu método de pago', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 24),
            _MethodItem(icon: Icons.credit_card_rounded, label: 'Tarjeta de Crédito/Débito', onTap: () => _pay(context, amount, PaymentProvider.culqi)),
            const SizedBox(height: 12),
            _MethodItem(icon: Icons.account_balance_wallet_rounded, label: 'Mercado Pago / Yape', onTap: () => _pay(context, amount, PaymentProvider.mercadoPago)),
          ],
        ),
      ),
    );
  }

  void _pay(BuildContext context, double amount, PaymentProvider provider) {
    Navigator.pop(context);
    context.read<AuthBloc>().add(Subscribe(provider: provider, amount: amount));
  }
}

class _MethodItem extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap;
  const _MethodItem({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: SoftCard(padding: const EdgeInsets.all(16), borderRadius: 16, child: Row(children: [
      Icon(icon, color: AppTheme.primaryColor), const SizedBox(width: 16),
      Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
      const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textPlaceholder),
    ])),
  );
}
