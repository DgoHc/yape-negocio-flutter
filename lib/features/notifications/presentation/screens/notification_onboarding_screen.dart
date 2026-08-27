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
  bool _isNotificationEnabled = false;
  bool _isAccessibilityEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    setState(() => _isLoading = true);
    final notification = await _service.isNotificationPermissionGranted();
    final accessibility = await _service.isAccessibilityServiceEnabled();
    
    AppLogger.d('Permissions: Notification: $notification | Accessibility: $accessibility');
    
    if (mounted) {
      setState(() {
        _isNotificationEnabled = notification;
        _isAccessibilityEnabled = accessibility;
        _isLoading = false;
      });
      
      // Si ambos están activos, ya podemos ir al dashboard
      if (notification && accessibility) {
        context.go('/dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: YtLoader()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración de Captura'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.security_update_good, size: 80, color: Color(0xFF7C4DFF)),
            const SizedBox(height: 32),
            const Text(
              'Activa SonoPay para Yape',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Para capturar pagos completos sin recortes, activa los siguientes permisos:',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            
            // Permiso 1: Notificaciones
            _PermissionTile(
              title: 'Acceso a Notificaciones',
              subtitle: 'Necesario para detectar el aviso de pago.',
              isEnabled: _isNotificationEnabled,
              onTap: () => _service.openNotificationSettings(),
            ),
            
            const SizedBox(height: 16),
            
            // Permiso 2: Accesibilidad
            _PermissionTile(
              title: 'Servicio de Scrapping',
              subtitle: 'Necesario para capturar nombres completos.',
              isEnabled: _isAccessibilityEnabled,
              onTap: () => _service.openAccessibilitySettings(),
            ),
            
            if (!_isAccessibilityEnabled)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  '💡 Si el botón está bloqueado: Ve a Información de la app > 3 puntos (⋮) > Permitir ajustes restringidos.',
                  style: TextStyle(fontSize: 11, color: Colors.orange, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),

            const Spacer(),
            
            YtButton(
              label: 'Ir al Dashboard',
              isSecondary: true,
              onPressed: () => context.go('/dashboard'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isEnabled;
  final VoidCallback onTap;

  const _PermissionTile({
    required this.title,
    required this.subtitle,
    required this.isEnabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      tileColor: isEnabled ? Colors.green.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Icon(
        isEnabled ? Icons.check_circle : Icons.warning_amber_rounded,
        color: isEnabled ? Colors.green : Colors.orange,
        size: 32,
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: isEnabled 
        ? const Text('ACTIVO', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
        : const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: isEnabled ? null : onTap,
    );
  }
}
