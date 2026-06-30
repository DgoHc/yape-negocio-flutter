
import 'package:flutter/material.dart' hide Border;
import 'package:flutter/material.dart' as flutter show Border;
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/yt_design_system.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../payments/presentation/bloc/payments_bloc.dart';
import '../../../notifications/data/notification_platform_service.dart';
import '../../../notifications/presentation/bloc/notification_bloc.dart';
import '../../../notifications/presentation/bloc/notification_event.dart';
import '../../../notifications/presentation/bloc/notification_state.dart';
import '../../../notifications/presentation/screens/linked_users_screen.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<PaymentsBloc>()..add(LoadPayments())),
        BlocProvider(create: (context) => sl<NotificationBloc>()..add(GetLinkRequests())),
      ],
      child: const DashboardView(),
    );
  }
}

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  (IconData, String) _getBusinessIconAndTitle(String? businessType) {
    switch (businessType?.toLowerCase()) {
      case 'transporte':
        return (Icons.local_taxi, 'Yape Transporte');
      case 'librería':
      case 'libreria':
        return (Icons.menu_book, 'Yape Librería');
      case 'restaurante':
        return (Icons.restaurant, 'Yape Restaurante');
      case 'servicios':
        return (Icons.build, 'Yape Servicios');
      case 'comercio':
        return (Icons.shop, 'Yape Comercio');
      default:
        return (Icons.store, 'Yape Negocios');
    }
  }

  Future<void> _exportToExcel(BuildContext context) async {
    final selection = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exportar Historial'),
        content: const Text('Selecciona el rango de tiempo para el reporte Excel:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'today'),
            child: const Text('Hoy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'month'),
            child: const Text('Este Mes'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'all'),
            child: const Text('Todo'),
          ),
        ],
      ),
    );

    if (selection == null) return;

    final now = DateTime.now();
    DateTime? startDate;
    DateTime? endDate;

    if (selection == 'today') {
      startDate = DateTime(now.year, now.month, now.day);
      endDate = startDate;
    } else if (selection == 'month') {
      startDate = DateTime(now.year, now.month, 1);
      endDate = DateTime(now.year, now.month + 1, 0);
    }

    if (!context.mounted) return;
    context.read<PaymentsBloc>().add(ExportPayments(
      startDate: startDate,
      endDate: endDate,
    ));
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text(
            '¿Estás seguro de que deseas salir? El dispositivo se desvinculará y deberá ser aprobado nuevamente para volver a entrar.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
              Navigator.pop(dialogContext);
            },
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaymentsBloc, PaymentsState>(
      builder: (context, paymentsState) {
        return BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            final profile = authState.userProfile;
            final (icon, title) = _getBusinessIconAndTitle(profile?.businessType);

            return Scaffold(
              appBar: AppBar(
                leading: Icon(icon, color: Theme.of(context).colorScheme.onPrimary),
                title: Text(title),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: () => _exportToExcel(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () => context.push('/settings'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () => _showLogoutDialog(context),
                  ),
                ],
              ),
              body: MultiBlocListener(
                listeners: [
                  BlocListener<AuthBloc, AuthState>(
                    listener: (context, state) {
                      if (state.status == AuthStatus.initial || state.status == AuthStatus.unauthenticated) {
                        context.go('/login');
                      }
                    },
                  ),
                ],
                child: paymentsState.status == PaymentsStatus.loading || paymentsState.status == PaymentsStatus.exporting
                    ? const Center(child: YtLoader())
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (profile != null && !profile.hasAccess)
                              const _RestrictedAccessBanner()
                            else if (profile != null && profile.isTrialActive && profile.trialEndDate != null)
                              _TrialExpiringBanner(trialEndDate: profile.trialEndDate!),
                            
                            const _PendingLinkRequestsBanner(),
                            const SizedBox(height: 8),
                            const _NotificationServiceStatus(),
                            const _TotalTodayCard(),
                            const SizedBox(height: 24),
                            const Text(
                              'Pagos Recientes',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            if (paymentsState.payments.isEmpty)
                              const Center(child: Text('Aún no hay pagos registrados')),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: paymentsState.payments.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final payment = paymentsState.payments[index];
                                return YtCard(
                                  child: ListTile(
                                    leading: const CircleAvatar(
                                      backgroundColor: Color(0xFF00BFA5),
                                      child: Icon(Icons.attach_money, color: Colors.white),
                                    ),
                                    title: Text(payment.senderName),
                                    subtitle: Text(
                                      '${payment.parsedAt.hour}:${payment.parsedAt.minute.toString().padLeft(2, '0')}',
                                    ),
                                    trailing: Text(
                                      '${payment.currency} ${payment.amount.toStringAsFixed(2)}',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 80), // Espacio para los FABs
                          ],
                        ),
                      ),
              ),
              floatingActionButton: const _DashboardFloatingControls(),
              floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            );
          },
        );
      },
    );
  }
}

class _DashboardFloatingControls extends StatelessWidget {
  const _DashboardFloatingControls();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Botón de Volumen
            FloatingActionButton(
              heroTag: 'vol_fab',
              backgroundColor: state.isMuted ? Colors.red : AppTheme.primaryColor,
              onPressed: () => context.read<SettingsBloc>().add(ToggleMute(!state.isMuted)),
              child: Icon(state.isMuted ? Icons.volume_off : Icons.volume_up, color: Colors.white),
            ),
            const SizedBox(width: 16),
            // Botón de Detección (ON/OFF - Campana)
            FloatingActionButton(
              heroTag: 'detect_fab',
              backgroundColor: state.isDetectionEnabled ? Colors.green : Colors.redAccent,
              onPressed: () => context.read<SettingsBloc>().add(ToggleDetection(!state.isDetectionEnabled)),
              child: Icon(
                state.isDetectionEnabled ? Icons.notifications_active : Icons.notifications_off,
                color: Colors.white,
              ),
            ),
          ],
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
    if (daysLeft < 0) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: flutter.Border.all(color: Colors.orange),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer_outlined, color: Colors.orange, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tu prueba gratuita finaliza en $daysLeft días.',
              style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: () => context.push('/subscription'),
            child: const Text('Suscribirse', style: TextStyle(color: Colors.orange, decoration: TextDecoration.underline)),
          )
        ],
      ),
    );
  }
}

class _RestrictedAccessBanner extends StatelessWidget {
  const _RestrictedAccessBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: flutter.Border.all(color: Colors.red),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Suscripción Expirada',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Tu plan ha terminado. Ya no se detectarán tus propios pagos, pero aún puedes recibir notificaciones de otros usuarios vinculados.',
            style: TextStyle(fontSize: 12, color: Colors.red),
          ),
          const SizedBox(height: 12),
          YtButton(
            label: 'Renovar Plan',
            onPressed: () => context.push('/subscription'),
          ),
        ],
      ),
    );
  }
}

class _PendingLinkRequestsBanner extends StatelessWidget {
  const _PendingLinkRequestsBanner();

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final currentUserId = authState.userProfile?.id;

    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        // Solo mostramos solicitudes donde el usuario actual es el RECEPTOR y están PENDIENTES
        final pendingRequests = state.linkRequests?.where((req) {
          final isPending = req.status.toLowerCase() == 'pending';
          final isReceiver = req.receiverId == currentUserId;
          return isPending && isReceiver;
        }).toList() ?? [];
        
        if (pendingRequests.isEmpty) return const SizedBox.shrink();

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: flutter.Border.all(color: Colors.green),
          ),
          child: Row(
            children: [
              const Icon(Icons.person_add_alt_1, color: Colors.green, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${pendingRequests.length} Solicitud${pendingRequests.length > 1 ? 'es' : ''} de vinculación',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const Text(
                      'Alguien quiere recibir tus notificaciones de pago.',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LinkedUsersScreen()),
                  );
                  // Al volver de la pantalla, refrescamos el estado para que el banner desaparezca si se aceptó
                  if (context.mounted) {
                    context.read<NotificationBloc>().add(GetLinkRequests());
                  }
                },
                child: const Text(
                  'Ver',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NotificationServiceStatus extends StatelessWidget {
  const _NotificationServiceStatus();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: sl<NotificationPlatformService>().notificationStream,
      builder: (context, snapshot) {
        final isConnected = snapshot.hasData && snapshot.data?['status'] == 'connected';
        return FutureBuilder<bool>(
            future: sl<NotificationPlatformService>().isNotificationPermissionGranted(),
            builder: (context, permSnapshot) {
              final hasPermission = permSnapshot.data ?? false;
              final active = isConnected || hasPermission;

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: active ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: flutter.Border.all(color: active ? Colors.green : Colors.red),
                ),
                child: InkWell(
                  onTap: hasPermission ? null : () => sl<NotificationPlatformService>().openNotificationSettings(),
                  child: Row(
                    children: [
                      Icon(
                        active ? Icons.check_circle : Icons.error,
                        color: active ? Colors.green : Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              active ? 'Servicio de Notificaciones: Activo' : 'Servicio de Notificaciones: Desactivado',
                              style: TextStyle(
                                fontSize: 12,
                                color: active ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (!hasPermission)
                              const Text(
                                'Toca aquí para activar el permiso en Android',
                                style: TextStyle(fontSize: 10, color: Colors.red),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            });
      },
    );
  }
}

class _TotalTodayCard extends StatelessWidget {
  const _TotalTodayCard();

  @override
  Widget build(BuildContext context) {
    final paymentsState = context.watch<PaymentsBloc>().state;
    return YtCard(
      child: Column(
        children: [
          const Text('Total Hoy', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text(
            'S/ ${paymentsState.dailyTotal.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00BFA5),
            ),
          ),
        ],
      ),
    );
  }
}
