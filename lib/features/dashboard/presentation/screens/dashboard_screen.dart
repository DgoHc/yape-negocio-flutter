import 'package:flutter/material.dart' hide Border;
import 'package:flutter/material.dart' as flutter show Border;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/yt_design_system.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/clipboard_payment_detector.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../payments/presentation/bloc/payments_bloc.dart';
import '../../../notifications/data/notification_platform_service.dart';
import '../../../notifications/presentation/bloc/notification_bloc.dart';
import '../../../notifications/presentation/bloc/notification_event.dart';
import '../../../notifications/presentation/bloc/notification_state.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider(create: (context) => sl<NotificationBloc>()..add(GetLinkRequests()), child: const DashboardView());
}

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});
  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => ClipboardPaymentDetector.checkClipboard(context));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) { if (state == AppLifecycleState.resumed) ClipboardPaymentDetector.checkClipboard(context); }

  (IconData, String) _getBusinessIconAndTitle(String? businessType) {
    switch (businessType?.toLowerCase()) {
      case 'transporte': return (Icons.local_taxi_rounded, 'SonoPay Transporte');
      case 'librería': case 'libreria': return (Icons.menu_book_rounded, 'SonoPay Librería');
      case 'restaurante': return (Icons.restaurant_rounded, 'SonoPay Restaurante');
      case 'servicios': return (Icons.build_circle_rounded, 'SonoPay Servicios');
      case 'comercio': return (Icons.shopping_bag_rounded, 'SonoPay Comercio');
      default: return (Icons.storefront_rounded, 'SonoPay Negocios');
    }
  }

  Future<void> _exportToExcel(BuildContext context) async {
    final now = DateTime.now();
    context.read<PaymentsBloc>().add(ExportPayments(startDate: DateTime(now.year, now.month, now.day), endDate: now));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Generando reporte Excel...')));
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.backgroundColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Cerrar Sesión', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('¿Estás seguro que deseas salir?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          AppButton(label: 'Salir', color: AppTheme.errorColor, onPressed: () { context.read<AuthBloc>().add(LogoutRequested()); Navigator.pop(ctx); }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaymentsBloc, PaymentsState>(builder: (context, paymentsState) {
      return BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
        final profile = authState.userProfile;
        final (icon, title) = _getBusinessIconAndTitle(profile?.businessType);
        return Scaffold(
          extendBodyBehindAppBar: true,
          body: MultiBlocListener(
            listeners: [BlocListener<AuthBloc, AuthState>(listener: (context, state) { if (state.status == AuthStatus.initial || state.status == AuthStatus.unauthenticated) context.go('/login'); })],
            child: paymentsState.status == PaymentsStatus.loading ? const Center(child: YtLoader()) : CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                  floating: true, snap: true, pinned: false,
                  backgroundColor: AppTheme.primaryColor, elevation: 0,
                  leading: Padding(padding: const EdgeInsets.all(10.0), child: Container(decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: Icon(icon, color: AppTheme.primaryColor, size: 18))),
                  title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                  actions: [
                    IconActionButton(icon: Icons.download_rounded, onTap: () => _exportToExcel(context)),
                    IconActionButton(icon: Icons.settings_suggest_rounded, onTap: () => context.push('/settings')),
                    IconActionButton(icon: Icons.logout_rounded, onTap: () => _showLogoutDialog(context)),
                    const SizedBox(width: 8),
                  ],
                ),
                SliverToBoxAdapter(child: Column(children: [
                  BrandBlobHeader(height: 140, isDashboard: true, child: Padding(padding: const EdgeInsets.only(top: 10, left: 24, right: 24), child: Column(children: [
                    const _NotificationServiceStatus(),
                    if (profile != null && profile.isTrialActive && profile.trialEndDate != null) Padding(padding: const EdgeInsets.only(top: 8), child: _TrialExpiringBanner(trialEndDate: profile.trialEndDate!)),
                    const _PendingLinkRequestsBanner(),
                  ]))),
                  const SizedBox(height: 20),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 24.0), child: _TotalTodayCard()),
                  const SizedBox(height: 32),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 24.0), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Pagos Recientes', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
                    TextButton(onPressed: () => context.push('/payment-history'), child: const Text('Ver todos', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary))),
                  ])),
                  const SizedBox(height: 12),
                ])),
                SliverPadding(padding: const EdgeInsets.symmetric(horizontal: 24), sliver: SliverList(delegate: SliverChildBuilderDelegate((context, index) => Padding(padding: const EdgeInsets.only(bottom: 16), child: _PaymentListItem(payment: paymentsState.payments[index])), childCount: paymentsState.payments.length > 5 ? 5 : paymentsState.payments.length))),
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          ),
          floatingActionButton: const _DashboardFloatingControls(),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      });
    });
  }
}

class _TotalTodayCard extends StatelessWidget {
  const _TotalTodayCard();
  @override
  Widget build(BuildContext context) => BlocBuilder<PaymentsBloc, PaymentsState>(builder: (context, state) => ClayContainer(color: AppTheme.primaryColor, borderRadius: 36, child: Container(padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24), decoration: BoxDecoration(borderRadius: BorderRadius.circular(36), gradient: LinearGradient(colors: [AppTheme.primaryColor, AppTheme.secondaryColor.withValues(alpha: 0.6)], begin: Alignment.topLeft, end: Alignment.bottomRight)), child: Column(children: [Text('BALANCE DE HOY', style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w900, color: const Color(0xFF3D2E00).withValues(alpha: 0.4), letterSpacing: 2.0)), const SizedBox(height: 12), FittedBox(child: Text('S/ ${state.dailyTotal.toStringAsFixed(2)}', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 52, color: const Color(0xFF2D2100), fontWeight: FontWeight.w900))), const SizedBox(height: 12), Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(20)), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.trending_up_rounded, color: Color(0xFF1B5E20), size: 16), const SizedBox(width: 8), Text('Ingresos en tiempo real', style: TextStyle(color: const Color(0xFF1B5E20).withValues(alpha: 0.8), fontWeight: FontWeight.bold, fontSize: 11))]))]))));
}

class _PaymentListItem extends StatelessWidget {
  final dynamic payment;
  const _PaymentListItem({required this.payment});
  @override
  Widget build(BuildContext context) {
    final initial = payment.senderName.isNotEmpty ? payment.senderName[0].toUpperCase() : '?';
    return SoftCard(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), borderRadius: 24, child: Row(children: [
      ClayContainer(height: 52, width: 52, borderRadius: 16, color: AppTheme.surfaceColor, child: Center(child: Text(initial, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w900, fontSize: 20)))),
      const SizedBox(width: 16),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(payment.senderName, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis), const SizedBox(height: 4), Row(children: [const Icon(Icons.access_time_filled_rounded, size: 14, color: AppTheme.textSecondary), const SizedBox(width: 5), Text('${payment.parsedAt.hour.toString().padLeft(2, '0')}:${payment.parsedAt.minute.toString().padLeft(2, '0')}', style: Theme.of(context).textTheme.labelSmall)])])),
      const SizedBox(width: 12),
      Text('${payment.currency} ${payment.amount.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.successColor, fontSize: 19, fontWeight: FontWeight.w900)),
    ]));
  }
}

class _DashboardFloatingControls extends StatelessWidget {
  const _DashboardFloatingControls();
  @override
  Widget build(BuildContext context) => BlocBuilder<SettingsBloc, SettingsState>(builder: (context, state) => Column(mainAxisSize: MainAxisSize.min, children: [
    FloatingActionButton(heroTag: 'vol', elevation: 6, backgroundColor: state.isMuted ? AppTheme.errorColor : AppTheme.primaryColor, onPressed: () => context.read<SettingsBloc>().add(ToggleMute(!state.isMuted)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), child: Icon(state.isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded, color: const Color(0xFF3D2E00))),
    const SizedBox(height: 16),
    FloatingActionButton(heroTag: 'det', elevation: 6, backgroundColor: state.isDetectionEnabled ? AppTheme.successColor : AppTheme.errorColor, onPressed: () => context.read<SettingsBloc>().add(ToggleDetection(!state.isDetectionEnabled)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), child: Icon(state.isDetectionEnabled ? Icons.notifications_active_rounded : Icons.notifications_off_rounded, color: const Color(0xFF3D2E00))),
  ]));
}

class _NotificationServiceStatus extends StatefulWidget {
  const _NotificationServiceStatus();
  @override
  State<_NotificationServiceStatus> createState() => _NotificationServiceStatusState();
}

class _NotificationServiceStatusState extends State<_NotificationServiceStatus> with WidgetsBindingObserver {
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermission();
    }
  }

  Future<void> _checkPermission() async {
    final granted = await sl<NotificationPlatformService>().isNotificationPermissionGranted();
    if (mounted) setState(() => _hasPermission = granted);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: sl<NotificationPlatformService>().notificationStream,
      builder: (context, snapshot) {
        final isConnected = snapshot.hasData && snapshot.data?['status'] == 'connected';
        final active = isConnected || _hasPermission;
        return InkWell(
          onTap: active ? null : () => sl<NotificationPlatformService>().openNotificationSettings(),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: active ? AppTheme.successColor.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(18),
              border: active ? null : flutter.Border.all(color: AppTheme.errorColor.withValues(alpha: 0.4), width: 1.5),
            ),
            child: Row(
              children: [
                Icon(active ? Icons.check_circle_rounded : Icons.error_rounded, color: active ? const Color(0xFF1B5E20) : AppTheme.errorColor, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    active ? 'Servicio de Notificaciones: ACTIVO' : 'Activar Permiso de Notificaciones',
                    style: TextStyle(fontSize: 12, color: active ? const Color(0xFF1B5E20) : AppTheme.errorColor, fontWeight: FontWeight.w900),
                  ),
                ),
                if (!active) const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppTheme.errorColor),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TrialExpiringBanner extends StatelessWidget {
  final DateTime trialEndDate;
  const _TrialExpiringBanner({required this.trialEndDate});
  @override
  Widget build(BuildContext context) {
    final daysLeft = trialEndDate.difference(DateTime.now()).inDays;
    return daysLeft < 0 ? const SizedBox.shrink() : ClayContainer(color: Colors.white.withValues(alpha: 0.95), borderRadius: 16, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Row(children: [const Icon(Icons.stars_rounded, color: AppTheme.primaryColor, size: 20), const SizedBox(width: 10), Expanded(child: Text('Prueba gratuita: $daysLeft días restantes.', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 12))), TextButton(onPressed: () => context.push('/subscription'), child: const Text('Mejorar Plan', style: TextStyle(fontWeight: FontWeight.w900, decoration: TextDecoration.underline, fontSize: 12)))]));
  }
}

class _PendingLinkRequestsBanner extends StatelessWidget {
  const _PendingLinkRequestsBanner();
  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    return BlocBuilder<NotificationBloc, NotificationState>(builder: (context, state) {
      final pending = state.linkRequests?.where((req) => req.status.toLowerCase() == 'pending' && req.receiverId == authState.userProfile?.id).toList() ?? [];
      return pending.isEmpty ? const SizedBox.shrink() : Padding(padding: const EdgeInsets.only(top: 8), child: ClayContainer(color: AppTheme.successColor.withValues(alpha: 0.95), borderRadius: 16, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), child: Row(children: [const Icon(Icons.person_add_rounded, color: Colors.white, size: 18), const SizedBox(width: 10), const Expanded(child: Text('Solicitudes de vinculación', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11))), TextButton(onPressed: () => context.push('/settings'), child: const Text('REVISAR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, decoration: TextDecoration.underline, fontSize: 11)))])));
    });
  }
}

class _RestrictedAccessBanner extends StatelessWidget {
  const _RestrictedAccessBanner();
  @override
  Widget build(BuildContext context) => SoftCard(color: AppTheme.errorColor.withValues(alpha: 0.1), padding: const EdgeInsets.all(20), borderRadius: 24, child: Column(children: [Row(children: [const Icon(Icons.warning_rounded, color: AppTheme.errorColor, size: 32), const SizedBox(width: 16), Expanded(child: Text('Suscripción Expirada', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.errorColor, fontWeight: FontWeight.w900)))]), const SizedBox(height: 12), const Text('Tu plan ha terminado. Suscríbete para continuar.', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)), const SizedBox(height: 20), AppButton(label: 'Ver Planes', onPressed: () => context.push('/subscription'))]));
}
