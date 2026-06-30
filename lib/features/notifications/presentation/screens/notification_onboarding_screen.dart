import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/widgets/yt_design_system.dart';
import '../../data/notification_platform_service.dart';

class NotificationOnboardingScreen extends StatefulWidget {
  const NotificationOnboardingScreen({super.key});

  @override
  State<NotificationOnboardingScreen> createState() => _NotificationOnboardingScreenState();
}

class _NotificationOnboardingScreenState extends State<NotificationOnboardingScreen> with WidgetsBindingObserver {
  final _service = sl<NotificationPlatformService>();
  bool _isChecking = false;

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
    final isGranted = await _service.isNotificationPermissionGranted();
    AppLogger.d('Notification Permission Status: $isGranted');
    if (isGranted && mounted) {
      // Si ya tiene el permiso, lo enviamos al dashboard
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.notifications_active, size: 80, color: Color(0xFF00BFA5)),
            const SizedBox(height: 32),
            const Text(
              'Activar Notificaciones',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Para que Yape Transporte pueda detectar tus pagos automáticamente, necesitamos acceso a tus notificaciones.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            YtButton(
              label: 'Dar Permiso',
              isLoading: _isChecking,
              onPressed: () async {
                setState(() => _isChecking = true);
                await _service.openNotificationSettings();
                setState(() => _isChecking = false);
              },
            ),
            const SizedBox(height: 16),
            YtButton(
              label: 'Más tarde',
              isSecondary: true,
              onPressed: () => context.go('/dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
