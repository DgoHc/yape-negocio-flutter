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
      backgroundColor: const Color(0xFFF9FAFC),
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
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              RefreshIndicator(
                onRefresh: () async {
                  context.read<PaymentsBloc>().add(LoadPayments());
                  context.read<SettingsBloc>().add(LoadControlSettings());
                },
                color: const Color(0xFF2C2200),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.only(bottom: 120),
                  child: BlocBuilder<SettingsBloc, SettingsState>(
                    builder: (context, settingsState) {
                      return BlocBuilder<PaymentsBloc, PaymentsState>(
                        builder: (context, paymentsState) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // --- 1. BLOQUE SUPERIOR AMARILLO ---
                              Container(
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFFCD19), // Amarillo Yape Cálido
                                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
                                ),
                                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                                child: Column(
                                  children: [
                                    // CABECERA SUPERIOR
                                    _HeaderCard(
                                      onExport: () {
                                        context.read<PaymentsBloc>().add(ExportPayments());
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Generando reporte Excel...')),
                                        );
                                      },
                                      onSettings: () => context.push('/settings'),
                                      onLogout: () => context.read<AuthBloc>().add(const LogoutRequested()),
                                    ),

                                    const SizedBox(height: 12),

                                    // PASTILLA 1: NOTIFICACIONES ACTIVAS
                                    _StatusPill(
                                      isDetectionActive: settingsState.isDetectionEnabled,
                                    ),

                                    const SizedBox(height: 8),

                                    // PASTILLA 2: PRUEBA GRATUITA
                                    BlocBuilder<AuthBloc, AuthState>(
                                      builder: (context, authState) {
                                        final profile = authState.userProfile;
                                        if (profile != null && !profile.isSubscribed) {
                                          return _TrialPill(
                                            daysLeft: profile.daysLeft,
                                          );
                                        }
                                        return const SizedBox.shrink();
                                      },
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16),

                              // --- 2. TARJETA DE BALANCE CENTRADA ---
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: _BalanceCard(
                                  dailyTotal: paymentsState.dailyTotal,
                                ),
                              ),

                              const SizedBox(height: 28),

                              // --- 3. ENCABEZADO DE PAGOS RECIENTES ---
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Pagos recientes',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF2C2200),
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
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF7A6800),
                                          fontFamily: 'Plus Jakarta Sans',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 12),

                              // --- 4. LISTA DE PAGOS ---
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: paymentsState.payments.isEmpty
                                    ? const _EmptyPaymentsCard()
                                    : Column(
                                        children: paymentsState.payments
                                            .take(8)
                                            .map((payment) => Padding(
                                                  padding: const EdgeInsets.only(bottom: 10.0),
                                                  child: _PaymentItemRow(payment: payment),
                                                ))
                                            .toList(),
                                      ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ),

              // DOCK INFERIOR FLOTANTE
              const Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: _FloatingBottomDock(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- CABECERA DE LA TARJETA EN CREMA ---
class _HeaderCard extends StatelessWidget {
  final VoidCallback onExport;
  final VoidCallback onSettings;
  final VoidCallback onLogout;

  const _HeaderCard({
    required this.onExport,
    required this.onSettings,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8D6), // Crema suave
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_active_rounded,
              color: Color(0xFFFFC800),
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
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Color(0xFF2C2200),
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF0B3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, color: const Color(0xFF2C2200), size: 20),
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
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDetectionActive ? const Color(0xFFCCD642) : const Color(0xFFFF8A80),
        borderRadius: BorderRadius.circular(100),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _PulsingDot(
            color: isDetectionActive ? const Color(0xFF00E676) : Colors.white,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isDetectionActive ? 'Notificaciones activas' : 'Detección pausada',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: isDetectionActive ? const Color(0xFF2E4D00) : Colors.white,
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
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8D6),
        borderRadius: BorderRadius.circular(100),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        children: [
          const Icon(
            Icons.stars_rounded,
            color: Color(0xFFFFC800),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Prueba gratuita: $daysLeft días resta...',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2C2200),
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
          ),
          const SizedBox(width: 6),
          ElevatedButton(
            onPressed: () => context.push('/subscription'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFCD19),
              foregroundColor: const Color(0xFF2C2200),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
            ),
            child: const Text(
              'Mejorar plan',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
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
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0B8), // Crema cálida del balance
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'BALANCE DE HOY',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              color: Color(0xFF7A6800),
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),
          const SizedBox(height: 10),

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
                        color: Color(0xFF7A6800),
                      ),
                    ),
                    TextSpan(
                      text: dailyTotal.toStringAsFixed(2),
                      style: const TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.5,
                        color: Color(0xFF1F1700),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _PulsingDot(color: Color(0xFF00E676)),
                SizedBox(width: 8),
                Text(
                  'Ingresos en tiempo real',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E6B20),
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

// --- ESTADO VACÍO DE TARJETA ---
class _EmptyPaymentsCard extends StatelessWidget {
  const _EmptyPaymentsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.all(28),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 28,
            color: Color(0xFF7A6800),
          ),
          SizedBox(height: 10),
          Text(
            'Aún no hay pagos hoy',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Color(0xFF2C2200),
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Tus cobros aparecerán aquí.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF8C827A),
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),
        ],
      ),
    );
  }
}

// --- FILA DE PAGO INDIVIDUAL ---
class _PaymentItemRow extends StatelessWidget {
  final dynamic payment;

  const _PaymentItemRow({required this.payment});

  @override
  Widget build(BuildContext context) {
    final initial = payment.senderName.isNotEmpty ? payment.senderName[0].toUpperCase() : '?';
    final timeStr = '${payment.parsedAt.hour.toString().padLeft(2, '0')}:${payment.parsedAt.minute.toString().padLeft(2, '0')}';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFFFCD19),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF2C2200),
                  fontFamily: 'Plus Jakarta Sans',
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.senderName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2C2200),
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Yape · $timeStr',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8C827A),
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
              ],
            ),
          ),

          Text(
            '+ ${payment.currency} ${payment.amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Color(0xFF00893E),
              fontFamily: 'Plus Jakarta Sans',
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

// --- DOCK INFERIOR FLOTANTE CON BOTONES GRANDES REDONDEADOS ---
class _FloatingBottomDock extends StatelessWidget {
  const _FloatingBottomDock();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settingsState) {
        final isDetectionActive = settingsState.isDetectionEnabled;
        final isMuted = settingsState.isMuted;

        return Row(
          children: [
            Expanded(
              child: _DockPillButton(
                label: isMuted ? 'Audio Silenciado' : 'Audio Activado',
                icon: isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                backgroundColor: isMuted ? AppTheme.errorColor : const Color(0xFFFFC800),
                textColor: isMuted ? Colors.white : const Color(0xFF2C2200),
                onTap: () {
                  context.read<SettingsBloc>().add(
                        ToggleMute(!isMuted),
                      );
                },
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: _DockPillButton(
                label: isDetectionActive ? 'Notificaciones' : 'Inactivo',
                icon: isDetectionActive ? Icons.notifications_active_rounded : Icons.notifications_off_rounded,
                backgroundColor: isDetectionActive ? const Color(0xFF00E676) : AppTheme.errorColor,
                textColor: isDetectionActive ? const Color(0xFF2C2200) : Colors.white,
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
    );
  }
}

class _DockPillButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onTap;

  const _DockPillButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  State<_DockPillButton> createState() => _DockPillButtonState();
}

class _DockPillButtonState extends State<_DockPillButton> {
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
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(100), // Bordes 100% redondeados como la captura
            boxShadow: [
              BoxShadow(
                color: widget.backgroundColor.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 20, color: widget.textColor),
              const SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    widget.label,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: widget.textColor,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
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
