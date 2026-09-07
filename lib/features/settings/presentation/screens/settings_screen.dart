import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/yt_design_system.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../features/notifications/presentation/bloc/notification_bloc.dart';
import '../../../../features/notifications/presentation/bloc/notification_event.dart';
import '../../../../features/notifications/presentation/bloc/notification_state.dart';
import '../bloc/settings_bloc.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<SettingsBloc>()
          ..add(LoadSecondaryNumbers())
          ..add(LoadControlSettings()),
        ),
        BlocProvider(create: (context) => sl<NotificationBloc>()
          ..add(GetMyNotificationCode()),
      ),
      ],
      child: BlocListener<NotificationBloc, NotificationState>(
        listener: (context, state) {
          if (state.errorMessage != null && state.errorMessage!.contains('401')) {
            context.read<AuthBloc>().add(const LogoutRequested());
          }
        },
        child: const SettingsView(),
      ),
    );
  }
}

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Configuración'), 
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20), 
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/dashboard');
            }
          }
        )
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(title: 'Vinculación de Cuentas', icon: Icons.link_rounded),
            const SizedBox(height: 16),
            BlocBuilder<NotificationBloc, NotificationState>(
              builder: (context, state) {
                if (state.isLoading) return const Center(child: YtLoader());
                if (state.notificationCode == null) return const Text('No se pudo generar el código.');
                
                return SoftCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Text('Mi Código de Socio', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white, 
                          borderRadius: BorderRadius.circular(20), 
                          border: Border.all(color: AppTheme.surfaceColor, width: 2)
                        ),
                        child: QrImageView(data: state.notificationCode!, size: 140, version: QrVersions.auto),
                      ),
                      const SizedBox(height: 16),
                      Text(state.notificationCode!, style: Theme.of(context).textTheme.headlineMedium?.copyWith(letterSpacing: 3, color: AppTheme.textPrimary)),
                      const SizedBox(height: 24),
                      Row(children: [
                        Expanded(child: AppButton(label: 'Copiar', isSecondary: true, onPressed: () => Clipboard.setData(ClipboardData(text: state.notificationCode!)))),
                        const SizedBox(width: 12),
                        Expanded(child: AppButton(label: 'Compartir', onPressed: () => Share.share('Vincula tu SonoPay con mi código: ${state.notificationCode!}'))),
                      ]),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
            _SectionTitle(title: 'Preferencias de Historial', icon: Icons.history_rounded),
            const SizedBox(height: 16),
            BlocBuilder<SettingsBloc, SettingsState>(
              builder: (context, state) => SoftCard(
                padding: EdgeInsets.zero,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  title: const Text('Limpieza automática', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(state.retentionDays == 0 ? 'Nunca borrar' : 'Borrar cada ${state.retentionDays} días'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _showRetentionDialog(context),
                ),
              ),
            ),
            const SizedBox(height: 40),
            _SectionTitle(title: 'Alertas WhatsApp', icon: Icons.message_rounded),
            const SizedBox(height: 8),
            const Text('Envía alertas de pago a números adicionales.', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            const SizedBox(height: 16),
            AppButton(label: 'Agregar nuevo número', icon: Icons.add_circle_outline_rounded, onPressed: () => _showAddNumberDialog(context)),
            const SizedBox(height: 24),
            BlocBuilder<SettingsBloc, SettingsState>(
              builder: (context, state) {
                if (state.isLoading) return const Center(child: YtLoader());
                if (state.secondaryNumbers.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('Sin números registrados', style: TextStyle(color: AppTheme.textPlaceholder))));
                return ListView.separated(
                  shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.secondaryNumbers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final num = state.secondaryNumbers[index];
                    return SoftCard(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), borderRadius: 16, child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: ClayContainer(width: 40, height: 40, borderRadius: 10, color: const Color(0xFFE8F5E9), child: const Icon(Icons.chat_rounded, color: Colors.green, size: 20)),
                      title: Text(num.phoneNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: IconButton(icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.errorColor), onPressed: () => context.read<SettingsBloc>().add(DeleteSecondaryNumber(num.id))),
                    ));
                  },
                );
              },
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  void _showRetentionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Duración del Historial', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _retentionOption(context, '7 días', 7),
            _retentionOption(context, '15 días', 15),
            _retentionOption(context, '30 días', 30),
            _retentionOption(context, '90 días', 90),
            _retentionOption(context, 'Siempre', 0),
          ],
        ),
      ),
    );
  }

  Widget _retentionOption(BuildContext context, String label, int days) {
    return ListTile(
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      onTap: () {
        context.read<SettingsBloc>().add(UpdateRetentionDays(days));
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Historial se conservará por: $label')),
        );
      },
    );
  }

  void _showAddNumberDialog(BuildContext context) {
    final controller = TextEditingController();
    String selectedType = 'whatsapp';
    final settingsBloc = context.read<SettingsBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppTheme.backgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: const Text('Nuevo Número', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              YtTextField(
                controller: controller,
                label: 'Número de Celular',
                hintText: 'Ej. 51999888777',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                child: Text('Plataforma', style: Theme.of(context).textTheme.labelMedium),
              ),
              ClayContainer(
                color: AppTheme.surfaceColor,
                borderRadius: 16,
                isPressed: true,
                shadowIntensity: 0.3,
                child: DropdownButtonFormField<String>(
                  initialValue: selectedType,
                  decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 20)),
                  items: const [
                    DropdownMenuItem(value: 'whatsapp', child: Text('WhatsApp')),
                    DropdownMenuItem(value: 'telegram', child: Text('Telegram')),
                  ],
                  onChanged: (val) => setState(() => selectedType = val!),
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
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: const Color(0xFF3D2E00)),
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  settingsBloc.add(AddSecondaryNumber(controller.text, selectedType));
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title; final IconData icon;
  const _SectionTitle({required this.title, required this.icon});
  @override
  Widget build(BuildContext context) => Row(children: [Icon(icon, size: 20, color: AppTheme.textSecondary), const SizedBox(width: 10), Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900))]);
}
