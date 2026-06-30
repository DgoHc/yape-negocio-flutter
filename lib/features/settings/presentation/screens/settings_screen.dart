import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/yt_design_system.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/notifications/presentation/bloc/notification_bloc.dart';
import '../../../../features/notifications/presentation/bloc/notification_event.dart';
import '../../../../features/notifications/presentation/bloc/notification_state.dart';
import '../../../../features/notifications/presentation/screens/linked_users_screen.dart';
import '../bloc/settings_bloc.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<SettingsBloc>()
          ..add(LoadSecondaryNumbers())
          ..add(LoadBaseUrl()),
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
      appBar: AppBar(title: const Text('Configuración')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 24),
            const Text(
              'Notificaciones',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            BlocBuilder<NotificationBloc, NotificationState>(
              builder: (context, state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (state.isLoading)
                      const Center(child: YtLoader()),
                    if (state.errorMessage != null)
                      Text(
                        state.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    if (state.notificationCode != null)
                      YtCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Mi Código de Notificaciones',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: QrImageView(
                                data: state.notificationCode!,
                                version: QrVersions.auto,
                                size: 180.0,
                                backgroundColor: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: Text(
                                state.notificationCode!,
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF00BFA5)),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: YtButton(
                                    label: 'Copiar',
                                    onPressed: () async {
                                      await Clipboard.setData(ClipboardData(text: state.notificationCode!));
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Código copiado al portapapeles')),
                                        );
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: YtButton(
                                    label: 'Compartir',
                                    isSecondary: true,
                                    onPressed: () {
                                      Share.share(
                                        '¡Usa mi código de notificaciones de Yape Negocios para recibir notificaciones de mis pagos!\n\nCódigo: ${state.notificationCode!}',
                                        subject: 'Mi código de notificaciones de Yape Negocios',
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            YtButton(
                              label: 'Usuarios Vinculados',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const LinkedUsersScreen()),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 24),
            const Text(
              'Notificaciones Secundarias',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Los pagos detectados se enviarán también a estos números vía WhatsApp.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            YtButton(
              label: 'Agregar Número',
              onPressed: () => _showAddNumberDialog(context),
            ),
            const SizedBox(height: 24),
            BlocBuilder<SettingsBloc, SettingsState>(
              builder: (context, state) {
                if (state.isLoading) return const Center(child: YtLoader());
                if (state.secondaryNumbers.isEmpty) {
                  return const Center(child: Text('No hay números guardados'));
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.secondaryNumbers.length,
                  itemBuilder: (context, index) {
                    final item = state.secondaryNumbers[index];
                    return YtCard(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          item.type == 'whatsapp' ? Icons.chat : Icons.send,
                          color: item.type == 'whatsapp' ? Colors.green : Colors.blue,
                        ),
                        title: Text(item.phoneNumber),
                        subtitle: Text(item.type.toUpperCase()),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () {
                            context.read<SettingsBloc>().add(DeleteSecondaryNumber(item.id));
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
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
          title: const Text('Nuevo Número'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              YtTextField(
                controller: controller,
                label: 'Número de Celular',
                hintText: 'Ej. 51999888777',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(labelText: 'Plataforma'),
                items: const [
                  DropdownMenuItem(value: 'whatsapp', child: Text('WhatsApp')),
                  DropdownMenuItem(value: 'telegram', child: Text('Telegram')),
                ],
                onChanged: (val) => setState(() => selectedType = val!),
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
