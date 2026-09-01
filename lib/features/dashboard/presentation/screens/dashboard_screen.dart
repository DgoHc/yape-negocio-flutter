
import 'package:flutter/material.dart' hide Border;
import 'package:flutter/material.dart' as flutter show Border;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/yt_design_system.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/clipboard_payment_detector.dart';
import '../../../../features/notifications/domain/parsers/payment_parser.dart';
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
    return BlocProvider(
      create: (context) => sl<NotificationBloc>()..add(GetLinkRequests()),
      child: const DashboardView(),
    );
  }
}

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Verificar portapapeles al iniciar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkClipboard();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkClipboard();
    }
  }

  void _checkClipboard() {
    if (mounted) {
      ClipboardPaymentDetector.checkClipboard(context);
    }
  }

  (IconData, String) _getBusinessIconAndTitle(String? businessType) {
    switch (businessType?.toLowerCase()) {
      case 'transporte':
        return (Icons.local_taxi, 'SonoPay Transporte');
      case 'librería':
      case 'libreria':
        return (Icons.menu_book, 'SonoPay Librería');
      case 'restaurante':
        return (Icons.restaurant, 'SonoPay Restaurante');
      case 'servicios':
        return (Icons.build, 'SonoPay Servicios');
      case 'comercio':
        return (Icons.shop, 'SonoPay Comercio');
      default:
        return (Icons.store, 'SonoPay Negocios');
    }
  }

  Future<void> _exportToExcel(BuildContext context) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final selection = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF151026) : Colors.white,
        title: const Text('Exportar Historial', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Selecciona el rango de tiempo para el reporte Excel:'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'today'),
            child: const Text('Hoy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'month'),
            child: const Text('Este Mes'),
          ),
          ElevatedButton(
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF151026) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Cerrar Sesión', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
            '¿Estás seguro de que deseas salir? El dispositivo se desvinculará y deberá ser aprobado nuevamente para volver a entrar.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor, foregroundColor: Colors.white),
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

  void _showManualPasteDialog(BuildContext context) {
    final controller = TextEditingController();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF151026) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Pegar Recibo de Pago', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Copia el texto del recibo de pago y pégalo aquí abajo para registrarlo automáticamente:',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Ej: ¡Yapeaste! o ¡Plineaste! S/ 5.00 a JUAN PEREZ. Nro. operación: 12345678...',
                filled: true,
                fillColor: isDark ? const Color(0xFF1B1437) : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                Navigator.pop(dialogContext);
                final result = PaymentParser.parse(text);
                result.fold(
                  (failure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Formato no reconocido: ${failure.message}'),
                        backgroundColor: AppTheme.errorColor,
                      ),
                    );
                  },
                  (payment) {
                    context.read<PaymentsBloc>().add(SaveManualPayment(payment));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Pago de ${payment.senderName} registrado con éxito'),
                        backgroundColor: AppTheme.successColor,
                      ),
                    );
                  },
                );
              }
            },
            child: const Text('Procesar'),
          ),
        ],
      ),
    );
  }

  void _showDynamicQrDialog(BuildContext context) {
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    bool generated = false;
    double amount = 0.0;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: isDark ? const Color(0xFF151026) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            title: Text(
              generated ? 'Código QR de Cobro' : 'Generar Cobro QR',
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!generated) ...[
                    const Text(
                      'Ingresa el monto que deseas cobrar para generar un código QR rápido.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    YtTextField(
                      controller: amountController,
                      label: 'Monto (S/)',
                      hintText: 'Ej. 3.50',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      prefixIcon: Icons.payments_outlined,
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Ingresa un monto';
                        final double? parsed = double.tryParse(val);
                        if (parsed == null || parsed <= 0) return 'Monto inválido';
                        return null;
                      },
                    ),
                  ] else ...[
                    const Text(
                      'Muestra este código al cliente para que te pague directamente:',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: flutter.Border.all(color: const Color(0xFF7C4DFF).withValues(alpha: 0.15)),
                      ),
                      child: QrImageView(
                        // Se simula la URL de Yape con el monto
                        data: 'yape://pay?amount=$amount',
                        version: QrVersions.auto,
                        size: 200,
                        gapless: false,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: Color(0xFF7C4DFF),
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.circle,
                          color: Color(0xFF151026),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'S/ ${amount.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF00E676)),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Una vez pagado, copia el recibo de pago para confirmarlo.',
                      style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cerrar'),
              ),
              if (!generated)
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      setState(() {
                        amount = double.parse(amountController.text);
                        generated = true;
                      });
                    }
                  },
                  child: const Text('Generar QR'),
                ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<PaymentsBloc, PaymentsState>(
      builder: (context, paymentsState) {
        return BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            final profile = authState.userProfile;
            final (icon, title) = _getBusinessIconAndTitle(profile?.businessType);

            return Scaffold(
              appBar: AppBar(
                leading: Icon(icon, color: isDark ? Colors.white : AppTheme.primaryColor),
                title: Text(title),
                actions: [
                  IconButton(
                    tooltip: 'Exportar Excel',
                    icon: const Icon(Icons.download_rounded),
                    onPressed: () => _exportToExcel(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_suggest_rounded),
                    onPressed: () => context.push('/settings'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout_rounded),
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
                            
                            // Muestra el total de hoy
                            const _TotalTodayCard(),
                            
                            const SizedBox(height: 28),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Pagos Recientes',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                ),
                                TextButton(
                                  onPressed: () => context.push('/payment-history'),
                                  child: const Text('Ver historial'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (paymentsState.payments.isEmpty)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                                  child: Column(
                                    children: [
                                      Icon(Icons.payment_outlined, size: 48, color: Colors.grey.withValues(alpha: 0.5)),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'Aún no hay pagos registrados',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: paymentsState.payments.length > 5 ? 5 : paymentsState.payments.length, // Mostrar solo los 5 más recientes
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final payment = paymentsState.payments[index];
                                final initial = payment.senderName.isNotEmpty ? payment.senderName[0].toUpperCase() : '?';

                                return YtCard(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  borderRadius: 20,
                                  child: Row(
                                    children: [
                                      ClayContainer(
                                        height: 48,
                                        width: 48,
                                        color: AppTheme.secondaryColor,
                                        borderRadius: 14,
                                        child: Center(
                                          child: Text(
                                            initial,
                                            style: const TextStyle(
                                              color: AppTheme.textPrimary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              payment.senderName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                                color: AppTheme.textPrimary,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(Icons.access_time, size: 12, color: AppTheme.textSecondary),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${payment.parsedAt.hour.toString().padLeft(2, '0')}:${payment.parsedAt.minute.toString().padLeft(2, '0')}',
                                                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        '${payment.currency} ${payment.amount.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 18,
                                          color: AppTheme.successColor,
                                          fontFeatures: [FontFeature.tabularFigures()],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 100), // Espacio para los FABs
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
                            if (!active)
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
      color: AppTheme.primaryColor,
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            Text(
              'Total de hoy',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'S/ ${paymentsState.dailyTotal.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.displayLarge,
            ),
          ],
        ),
      ),
    );
  }
}
