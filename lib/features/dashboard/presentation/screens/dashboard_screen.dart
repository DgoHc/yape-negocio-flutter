import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/yt_design_system.dart';
import '../../../../core/utils/clipboard_payment_detector.dart';
import '../../../../core/services/tts_service.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../payments/presentation/bloc/payments_bloc.dart';
import '../../../notifications/data/notification_platform_service.dart';
import '../../../notifications/presentation/bloc/notification_bloc.dart';
import '../../../notifications/presentation/bloc/notification_event.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';

// --- TOKENS DE DISEÑO DESIGNADOS ---
class DashboardDesignTokens {
  static const Color cYellowMain = Color(0xFFFFC93C);
  static const Color cYellowLight = Color(0xFFFFD966);
  static const Color cGreenMain = Color(0xFF22C55E);
  static const Color cGreenDarkText = Color(0xFF166534);
  static const Color cDarkBrownMain = Color(0xFF2A1F00);
  static const Color cDarkBrownSecondary = Color(0xFF7A6420);
  static const Color cBg = Color(0xFFF7F8FC);
  static const Color cGreyText = Color(0xFF6B7280);

  static const List<BoxShadow> softGlassShadow = [
    BoxShadow(
      color: Color(0x12000000),
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ];
}

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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ClipboardPaymentDetector.checkClipboard(context);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ClipboardPaymentDetector.checkClipboard(context);
    }
  }

  Future<void> _exportToExcel(BuildContext context) async {
    final now = DateTime.now();
    context.read<PaymentsBloc>().add(
          ExportPayments(
            startDate: DateTime(now.year, now.month, now.day),
            endDate: now,
          ),
        );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generando reporte Excel...')),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Cerrar Sesión',
          style: TextStyle(fontWeight: FontWeight.bold, color: DashboardDesignTokens.cDarkBrownMain),
        ),
        content: const Text(
          '¿Estás seguro que deseas salir de SonoPay?',
          style: TextStyle(color: DashboardDesignTokens.cGreyText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          AppButton(
            label: 'Salir',
            color: AppTheme.errorColor,
            onPressed: () {
              context.read<AuthBloc>().add(const LogoutRequested());
              Navigator.pop(ctx);
            },
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

            return Scaffold(
              backgroundColor: DashboardDesignTokens.cBg,
              body: MultiBlocListener(
                listeners: [
                  BlocListener<AuthBloc, AuthState>(
                    listener: (context, state) {
                      if (state.status == AuthStatus.initial ||
                          state.status == AuthStatus.unauthenticated) {
                        context.go('/login');
                      }
                    },
                  ),
                ],
                child: Stack(
                  children: [
                    // 1. FONDO SUPERIOR AMARILLO SÓLIDO CON BORDE CURVO ELÍPTICO
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 280,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: DashboardDesignTokens.cYellowMain,
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.elliptical(400, 68),
                          ),
                        ),
                      ),
                    ),

                    // 2. CONTENIDO PRINCIPAL EN UN SOLO SCROLL
                    SafeArea(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),

                              // HEADER EN VIDRIO
                              _GlassHeader(
                                onExport: () => _exportToExcel(context),
                                onSettings: () => context.push('/settings'),
                                onLogout: () => _showLogoutDialog(context),
                              ),

                              const SizedBox(height: 16),

                              // PASTILLA DE ESTADO Y PRUEBA GRATUITA
                              Row(
                                children: [
                                  const Expanded(child: _StatusPill()),
                                  if (profile != null && profile.isTrialActive && profile.trialEndDate != null) ...[
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _TrialPill(
                                        daysLeft: profile.trialEndDate!
                                            .difference(DateTime.now())
                                            .inDays,
                                      ),
                                    ),
                                  ],
                                ],
                              ),

                              const SizedBox(height: 32),

                              // TARJETA DE BALANCE EN VIDRIO AMARILLO LIGERO
                              _BalanceCard(
                                dailyTotal: paymentsState.dailyTotal,
                              ),

                              const SizedBox(height: 36),

                              // ENCABEZADO DE SECCIÓN
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Pagos recientes',
                                    style: TextStyle(
                                      fontSize: 21,
                                      fontWeight: FontWeight.w800,
                                      color: DashboardDesignTokens.cDarkBrownMain,
                                      fontFamily: 'Plus Jakarta Sans',
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => context.push('/payment-history'),
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text(
                                      'Ver todos',
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                        color: DashboardDesignTokens.cDarkBrownSecondary,
                                        fontFamily: 'Plus Jakarta Sans',
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // LISTA DE PAGOS O ESTADO VACÍO
                              if (paymentsState.payments.isEmpty)
                                const _EmptyPaymentsGlassCard()
                              else
                                Column(
                                  children: paymentsState.payments
                                      .take(5)
                                      .map((payment) => Padding(
                                            padding: const EdgeInsets.only(bottom: 12.0),
                                            child: _PaymentRowItem(payment: payment),
                                          ))
                                      .toList(),
                                ),

                              // Padding inferior suficiente para que el Dock no tape contenido
                              const SizedBox(height: 130),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // 3. DOCK INFERIOR FLOTANTE EN VIDRIO
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 18,
                      child: SafeArea(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 388),
                            child: const _FloatingBottomDock(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// --- CONTENEDOR DE VIDRIO REUTILIZABLE (GLASS CONTAINER) ---
class _GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;

  const _GlassContainer({
    required this.child,
    this.borderRadius = 26,
    this.backgroundColor = const Color(0x6BFFFFFF), // Blanco 42%
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: const Color(0xBFFFFFFF), width: 1.0), // Borde blanco 75%
            boxShadow: DashboardDesignTokens.softGlassShadow,
          ),
          child: child,
        ),
      ),
    );
  }
}

// --- 2. HEADER EN VIDRIO ---
class _GlassHeader extends StatelessWidget {
  final VoidCallback onExport;
  final VoidCallback onSettings;
  final VoidCallback onLogout;

  const _GlassHeader({
    required this.onExport,
    required this.onSettings,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassContainer(
      borderRadius: 26,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Logo circular blanco de 44 dp con icono llave amarilla
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_active_rounded,
              color: DashboardDesignTokens.cYellowMain,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),

          // Título SonoPay
          const Expanded(
            child: Text(
              'SonoPay',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: DashboardDesignTokens.cDarkBrownMain,
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
          ),

          // 3 Botones de vidrio de 42 dp
          _HeaderIconButton(icon: Icons.download_rounded, onTap: onExport),
          const SizedBox(width: 6),
          _HeaderIconButton(icon: Icons.settings_rounded, onTap: onSettings),
          const SizedBox(width: 6),
          _HeaderIconButton(icon: Icons.logout_rounded, onTap: onLogout),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0x6BFFFFFF),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xBFFFFFFF), width: 1.0),
        ),
        child: Icon(
          icon,
          size: 20,
          color: DashboardDesignTokens.cDarkBrownMain,
        ),
      ),
    );
  }
}

// --- 3. PASTILLA DE ESTADO EN VIDRIO ---
class _StatusPill extends StatefulWidget {
  const _StatusPill();

  @override
  State<_StatusPill> createState() => _StatusPillState();
}

class _StatusPillState extends State<_StatusPill> with WidgetsBindingObserver {
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

        return _GlassContainer(
          borderRadius: 100, // Radio completo
          backgroundColor: active ? const Color(0x3822C55E) : const Color(0x38EF4444), // Verde o Rojo al 22%
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: InkWell(
            onTap: active ? null : () => sl<NotificationPlatformService>().openNotificationSettings(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _PulsingDot(color: active ? DashboardDesignTokens.cGreenMain : AppTheme.errorColor),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    active ? 'Notificaciones activas' : 'Notificaciones inactivas',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: active ? DashboardDesignTokens.cGreenDarkText : AppTheme.errorColor,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// --- PUNTO VERDE PULSANTE SUAVE ---
class _PulsingDot extends StatefulWidget {
  final Color color;

  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _PulsingDotPainter(_controller.value, widget.color),
          child: SizedBox(width: 10, height: 10),
        );
      },
    );
  }
}

class _PulsingDotPainter extends CustomPainter {
  final double progress;
  final Color color;

  _PulsingDotPainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width / 2;

    // Anillo exterior que crece hasta 3x y se desvanece
    final ringRadius = baseRadius + (progress * baseRadius * 2);
    final ringOpacity = (1.0 - progress).clamp(0.0, 1.0);
    final ringPaint = Paint()
      ..color = color.withValues(alpha: ringOpacity * 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(center, ringRadius, ringPaint);

    // Punto central sólido
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, baseRadius, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _PulsingDotPainter oldDelegate) => true;
}

// --- 4. PASTILLA DE PRUEBA GRATUITA ---
class _TrialPill extends StatelessWidget {
  final int daysLeft;

  const _TrialPill({required this.daysLeft});

  @override
  Widget build(BuildContext context) {
    return _GlassContainer(
      borderRadius: 100,
      backgroundColor: const Color(0x9EFFFFFF), // Blanco al 62%
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Text(
              'Prueba: $daysLeft días',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: DashboardDesignTokens.cDarkBrownMain,
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: () => context.push('/subscription'),
            borderRadius: BorderRadius.circular(100),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: DashboardDesignTokens.cYellowMain,
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Text(
                'Mejorar plan',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: DashboardDesignTokens.cDarkBrownMain,
                  fontFamily: 'Plus Jakarta Sans',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- 5. TARJETA DE BALANCE DE HOY EN VIDRIO ---
class _BalanceCard extends StatelessWidget {
  final double dailyTotal;

  const _BalanceCard({required this.dailyTotal});

  @override
  Widget build(BuildContext context) {
    return _GlassContainer(
      borderRadius: 32,
      backgroundColor: const Color(0x80FFD966), // Amarillo claro #FFD966 al 50%
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          const Text(
            'BALANCE DE HOY',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.68, // 0.14em
              color: DashboardDesignTokens.cDarkBrownSecondary,
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),
          const SizedBox(height: 12),

          // Monto con Cifras Tabulares
          FittedBox(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
                children: [
                  const TextSpan(
                    text: 'S/ ',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: DashboardDesignTokens.cDarkBrownSecondary,
                    ),
                  ),
                  TextSpan(
                    text: dailyTotal.toStringAsFixed(2),
                    style: const TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.5,
                      color: DashboardDesignTokens.cDarkBrownMain,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Pastilla "Ingresos en tiempo real"
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0x80FFFFFF), // Blanco al 50%
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: Colors.white, width: 1.0),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _PulsingDot(color: DashboardDesignTokens.cGreenMain),
                SizedBox(width: 8),
                Text(
                  'Ingresos en tiempo real',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: DashboardDesignTokens.cGreenDarkText,
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- 7. ESTADO VACÍO EN TARJETA DE VIDRIO ---
class _EmptyPaymentsGlassCard extends StatelessWidget {
  const _EmptyPaymentsGlassCard();

  @override
  Widget build(BuildContext context) {
    return _GlassContainer(
      borderRadius: 26,
      backgroundColor: const Color(0x80FFFFFF), // Blanco 50%
      padding: const EdgeInsets.all(28),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.notifications_none_rounded,
              size: 26,
              color: DashboardDesignTokens.cDarkBrownSecondary,
            ),
            const SizedBox(height: 10),
            const Text(
              'Aún no hay pagos hoy',
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
                color: DashboardDesignTokens.cDarkBrownMain,
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Tus cobros aparecerán aquí.',
              style: TextStyle(
                fontSize: 13,
                color: DashboardDesignTokens.cGreyText,
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 8. FILA DE PAGO EN VIDRIO ---
class _PaymentRowItem extends StatelessWidget {
  final dynamic payment;

  const _PaymentRowItem({required this.payment});

  @override
  Widget build(BuildContext context) {
    final initial = payment.senderName.isNotEmpty ? payment.senderName[0].toUpperCase() : '?';
    final timeStr = '${payment.parsedAt.hour.toString().padLeft(2, '0')}:${payment.parsedAt.minute.toString().padLeft(2, '0')}';

    return _GlassContainer(
      borderRadius: 22,
      backgroundColor: const Color(0x8CFFFFFF), // Blanco 55%
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          // Avatar cuadrado de 42 dp radio 14
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: DashboardDesignTokens.cYellowMain,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: DashboardDesignTokens.cDarkBrownMain,
                  fontFamily: 'Plus Jakarta Sans',
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Nombre y Método/Hora
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.senderName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: DashboardDesignTokens.cDarkBrownMain,
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Yape · $timeStr',
                  style: const TextStyle(
                    fontSize: 12,
                    color: DashboardDesignTokens.cGreyText,
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
              ],
            ),
          ),

          // Monto en verde oscuro
          Text(
            '+ ${payment.currency} ${payment.amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: DashboardDesignTokens.cGreenDarkText,
              fontFamily: 'Plus Jakarta Sans',
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

// --- 9. DOCK INFERIOR FLOTANTE EN VIDRIO ---
class _FloatingBottomDock extends StatelessWidget {
  const _FloatingBottomDock();

  @override
  Widget build(BuildContext context) {
    return _GlassContainer(
      borderRadius: 30,
      backgroundColor: const Color(0x80FFFFFF), // Blanco 50%
      padding: const EdgeInsets.all(8),
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settingsState) {
          return Row(
            children: [
              Expanded(
                child: _DockButton(
                  label: 'Probar sonido',
                  icon: Icons.volume_up_rounded,
                  backgroundColor: DashboardDesignTokens.cYellowMain,
                  textColor: DashboardDesignTokens.cDarkBrownMain,
                  onTap: () {
                    sl<TtsService>().speak('Prueba de audio SonoPay completada correctamente.');
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DockButton(
                  label: settingsState.isDetectionEnabled ? 'Notificaciones' : 'Silenciado',
                  icon: settingsState.isDetectionEnabled ? Icons.notifications_active_rounded : Icons.notifications_off_rounded,
                  backgroundColor: settingsState.isDetectionEnabled ? DashboardDesignTokens.cGreenMain : AppTheme.errorColor,
                  textColor: DashboardDesignTokens.cDarkBrownMain,
                  onTap: () {
                    context.read<SettingsBloc>().add(
                          ToggleDetection(!settingsState.isDetectionEnabled),
                        );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DockButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onTap;

  const _DockButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  State<_DockButton> createState() => _DockButtonState();
}

class _DockButtonState extends State<_DockButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0, // Reducción a escala 0.96 al presionar
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(23),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 20, color: widget.textColor),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: widget.textColor,
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
