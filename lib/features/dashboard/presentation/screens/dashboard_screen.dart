import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/di/injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../payments/presentation/bloc/payments_bloc.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../../notifications/data/notification_platform_service.dart';

// --- DESIGN TOKENS Y COLORES OFICIALES DEL DASHBOARD MÁS MODERNO ---
class DashboardDesignTokens {
  static const Color bgGradientTop = Color(0xFFFBFBFE);    // Blanco Nieve casi puro
  static const Color bgGradientMid = Color(0xFFF3F1FD);    // Violeta Pastel Místico
  static const Color bgGradientBottom = Color(0xFFFFF7E6); // Calidez Amarilla Suave

  static const Color cYellowMain = Color(0xFFFFD500);       // Amarillo Yape/Brillante
  static const Color cDarkBrownMain = Color(0xFF2C2420);    // Marrón Oscuro/Casi Negro
  static const Color cDarkBrownSecondary = Color(0xFF5A4E48); // Marrón Neutro
  static const Color cGreyText = Color(0xFF8C827A);          // Gris Suave
  static const Color cGreenMain = Color(0xFF00E676);        // Verde Neón para Notificaciones
  static const Color cGreenDarkText = Color(0xFF00893E);    // Verde Oscuro para montos
  static const Color cRedMain = Color(0xFFFF3B30);          // Rojo Alerta

  static final List<BoxShadow> softGlassShadow = [
    BoxShadow(
      color: const Color(0xFF2C2420).withValues(alpha: 0.04),
      blurRadius: 24,
      spreadRadius: 0,
      offset: const Offset(0, 10),
    ),
    BoxShadow(
      color: Colors.white.withValues(alpha: 0.6),
      blurRadius: 12,
      spreadRadius: -4,
      offset: const Offset(0, -4),
    ),
  ];
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final NotificationPlatformService _notificationService = sl<NotificationPlatformService>();

  @override
  void initState() {
    super.initState();
    context.read<PaymentsBloc>().add(LoadPayments());
    context.read<SettingsBloc>().add(LoadControlSettings());
    _checkNotificationPermissionOnStart();
  }

  Future<void> _checkNotificationPermissionOnStart() async {
    final isGranted = await _notificationService.isNotificationPermissionGranted();
    if (!isGranted && mounted) {
      context.push('/notification-onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state.status == AuthStatus.unauthenticated) {
                context.go('/login');
              } else if (state.status == AuthStatus.authenticatedDriver || state.status == AuthStatus.authenticatedAdmin) {
                context.read<PaymentsBloc>().add(LoadPayments());
              }
            },
          ),
          BlocListener<PaymentsBloc, PaymentsState>(
            listener: (context, state) {
              if (state.status == PaymentsStatus.failure && state.error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.error!),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
              }
            },
          ),
        ],
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                DashboardDesignTokens.bgGradientTop,
                DashboardDesignTokens.bgGradientMid,
                DashboardDesignTokens.bgGradientBottom,
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                // CONTENIDO SCROLLABLE PRINCIPAL
                RefreshIndicator(
                  onRefresh: () async {
                    context.read<PaymentsBloc>().add(LoadPayments());
                    context.read<SettingsBloc>().add(LoadControlSettings());
                  },
                  color: DashboardDesignTokens.cDarkBrownMain,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
                    child: BlocBuilder<SettingsBloc, SettingsState>(
                      builder: (context, settingsState) {
                        return BlocBuilder<PaymentsBloc, PaymentsState>(
                          builder: (context, paymentsState) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 1. CABECERA EN VIDRIO (LOGO + DOCK DE ACCIONES)
                                _GlassHeader(
                                  onExport: () {
                                    context.read<PaymentsBloc>().add(ExportPayments());
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Generando reporte Excel...')),
                                    );
                                  },
                                  onSettings: () => context.push('/settings'),
                                  onLogout: () => context.read<AuthBloc>().add(const LogoutRequested()),
                                ),

                                const SizedBox(height: 14),

                                // 2. PASTILLA 1: NOTIFICACIONES ACTIVAS / INACTIVAS
                                _StatusPill(
                                  isDetectionActive: settingsState.isDetectionEnabled,
                                ),

                                const SizedBox(height: 10),

                                // 3. PASTILLA 2: DIAS RESTANTES DE PRUEBA GRATUITA
                                BlocBuilder<AuthBloc, AuthState>(
                                  builder: (context, authState) {
                                    final profile = authState.userProfile;
                                    if (profile != null && !profile.isSubscribed) {
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 14.0),
                                        child: _TrialPill(
                                          daysLeft: profile.daysLeft,
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),

                                const SizedBox(height: 8),

                                // 4. TARJETA DE BALANCE EN VIDRIO AMARILLO LIGERO (PERFECTAMENTE CENTRADO)
                                RepaintBoundary(
                                  child: _BalanceCard(
                                    dailyTotal: paymentsState.dailyTotal,
                                  ),
                                ),

                                const SizedBox(height: 32),

                                // 5. ENCABEZADO DE SECCIÓN
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

                                const SizedBox(height: 14),

                                // 6. LISTA DE PAGOS O ESTADO VACÍO
                                if (paymentsState.payments.isEmpty)
                                  const _EmptyPaymentsGlassCard()
                                else
                                  Column(
                                    children: paymentsState.payments
                                        .take(8)
                                        .map((payment) => Padding(
                                              padding: const EdgeInsets.only(bottom: 12.0),
                                              child: _PaymentRowItem(payment: payment),
                                            ))
                                        .toList(),
                                  ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),

                // DOCK INFERIOR FLOTANTE CON EFECTO DE VIDRIO
                const Positioned(
                  left: 20,
                  right: 20,
                  bottom: 20,
                  child: RepaintBoundary(
                    child: _FloatingBottomDock(),
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

// --- CONTENEDOR DE VIDRIO OPTIMIZADO PARA ALTO RENDIMIENTO ---
class _GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;
  final bool useBlur;

  const _GlassContainer({
    required this.child,
    this.borderRadius = 26,
    this.backgroundColor = const Color(0x6BFFFFFF),
    this.padding = const EdgeInsets.all(16),
    this.useBlur = false,
  });

  @override
  Widget build(BuildContext context) {
    final container = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: const Color(0xBFFFFFFF), width: 1.0),
        boxShadow: DashboardDesignTokens.softGlassShadow,
      ),
      child: child,
    );

    if (!useBlur) {
      return container;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: container,
      ),
    );
  }
}

// --- HEADER EN VIDRIO ---
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
      useBlur: true,
      borderRadius: 26,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
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
          color: const Color(0x59FFFFFF),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 1.0),
        ),
        child: Icon(icon, color: DashboardDesignTokens.cDarkBrownMain, size: 20),
      ),
    );
  }
}

// --- PASTILLA DE ESTADO DE NOTIFICACIONES ---
class _StatusPill extends StatelessWidget {
  final bool isDetectionActive;

  const _StatusPill({required this.isDetectionActive});

  @override
  Widget build(BuildContext context) {
    return _GlassContainer(
      useBlur: false,
      borderRadius: 100,
      backgroundColor: const Color(0x9EFFFFFF),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _PulsingDot(
            color: isDetectionActive ? DashboardDesignTokens.cGreenMain : DashboardDesignTokens.cRedMain,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isDetectionActive ? 'Notificaciones de Yape y Plin activas' : 'Detección pausada',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: isDetectionActive ? DashboardDesignTokens.cDarkBrownMain : DashboardDesignTokens.cRedMain,
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
          child: const SizedBox(width: 10, height: 10),
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

    final ringRadius = baseRadius + (progress * baseRadius * 2);
    final ringOpacity = (1.0 - progress).clamp(0.0, 1.0);
    final ringPaint = Paint()
      ..color = color.withValues(alpha: ringOpacity * 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(center, ringRadius, ringPaint);

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, baseRadius, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _PulsingDotPainter oldDelegate) => true;
}

// --- PASTILLA DE PRUEBA GRATUITA ---
class _TrialPill extends StatelessWidget {
  final int daysLeft;

  const _TrialPill({required this.daysLeft});

  @override
  Widget build(BuildContext context) {
    return _GlassContainer(
      useBlur: false,
      borderRadius: 100,
      backgroundColor: const Color(0x9EFFFFFF),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: DashboardDesignTokens.cYellowMain,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Prueba gratuita: $daysLeft días restantes',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: DashboardDesignTokens.cDarkBrownSecondary,
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- TARJETA DE BALANCE ---
class _BalanceCard extends StatelessWidget {
  final double dailyTotal;

  const _BalanceCard({required this.dailyTotal});

  @override
  Widget build(BuildContext context) {
    return _GlassContainer(
      useBlur: true,
      borderRadius: 32,
      backgroundColor: const Color(0xB2FFF5AA),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'BALANCE DE HOY',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: DashboardDesignTokens.cDarkBrownSecondary,
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
            const SizedBox(height: 12),

            Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: RichText(
                  textAlign: TextAlign.center,
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
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0x80FFFFFF),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: Colors.white, width: 1.0),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
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
      ),
    );
  }
}

// --- ESTADO VACÍO EN TARJETA DE VIDRIO ---
class _EmptyPaymentsGlassCard extends StatelessWidget {
  const _EmptyPaymentsGlassCard();

  @override
  Widget build(BuildContext context) {
    return _GlassContainer(
      useBlur: false,
      borderRadius: 26,
      backgroundColor: const Color(0x80FFFFFF),
      padding: const EdgeInsets.all(28),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 26,
              color: DashboardDesignTokens.cDarkBrownSecondary,
            ),
            SizedBox(height: 10),
            Text(
              'Aún no hay pagos hoy',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
                color: DashboardDesignTokens.cDarkBrownMain,
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Tus cobros aparecerán aquí.',
              textAlign: TextAlign.center,
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

// --- FILA DE PAGO EN VIDRIO OPTIMIZADA PARA ALTO RENDIMIENTO ---
class _PaymentRowItem extends StatelessWidget {
  final dynamic payment;

  const _PaymentRowItem({required this.payment});

  @override
  Widget build(BuildContext context) {
    final initial = payment.senderName.isNotEmpty ? payment.senderName[0].toUpperCase() : '?';
    final timeStr = '${payment.parsedAt.hour.toString().padLeft(2, '0')}:${payment.parsedAt.minute.toString().padLeft(2, '0')}';

    return _GlassContainer(
      useBlur: false,
      borderRadius: 22,
      backgroundColor: const Color(0x8CFFFFFF),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
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

// --- DOCK INFERIOR FLOTANTE EN VIDRIO ---
class _FloatingBottomDock extends StatelessWidget {
  const _FloatingBottomDock();

  @override
  Widget build(BuildContext context) {
    return _GlassContainer(
      useBlur: true,
      borderRadius: 28,
      backgroundColor: const Color(0xB22C2420),
      padding: const EdgeInsets.all(6),
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settingsState) {
          final isDetectionActive = settingsState.isDetectionEnabled;
          final isMuted = settingsState.isMuted;

          return Row(
            children: [
              Expanded(
                child: _DockButton(
                  label: isMuted ? 'Audio Silenciado' : 'Audio Activado',
                  icon: isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                  backgroundColor: isMuted ? AppTheme.errorColor : DashboardDesignTokens.cYellowMain,
                  textColor: isMuted ? Colors.white : DashboardDesignTokens.cDarkBrownMain,
                  onTap: () {
                    context.read<SettingsBloc>().add(
                          ToggleMute(!isMuted),
                        );
                  },
                ),
              ),
              const SizedBox(width: 8),

              Expanded(
                child: _DockButton(
                  label: isDetectionActive ? 'Notificaciones' : 'Inactivo',
                  icon: isDetectionActive ? Icons.notifications_active_rounded : Icons.notifications_off_rounded,
                  backgroundColor: isDetectionActive ? DashboardDesignTokens.cGreenMain : AppTheme.errorColor,
                  textColor: isDetectionActive ? DashboardDesignTokens.cDarkBrownMain : Colors.white,
                  onTap: () {
                    context.read<SettingsBloc>().add(
                          ToggleDetection(!isDetectionActive),
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
        scale: _isPressed ? 0.96 : 1.0,
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
                    fontSize: 12.5,
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
