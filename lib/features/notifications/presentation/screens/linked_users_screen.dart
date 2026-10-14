import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/yt_design_system.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/notification_link_entities.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';
import 'add_link_screen.dart';

class LinkedUsersScreen extends StatelessWidget {
  const LinkedUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<NotificationBloc>()
        ..add(GetLinkRequests())
        ..add(GetLinkedUsers()),
      child: const LinkedUsersView(),
    );
  }
}

class LinkedUsersView extends StatelessWidget {
  const LinkedUsersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(title: const Text('Vinculación de Cuentas')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddLinkScreen()),
          );
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add_rounded, color: Color(0xFF3D2E00)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: YtLoader());
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- TARJETA DE MI CÓDIGO DE SOCIO ---
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, authState) {
                    final profile = authState.userProfile;
                    final code = profile?.notificationCode ?? profile?.id?.substring(0, 8).toUpperCase() ?? 'SONO-8899';

                    return SoftCard(
                      color: const Color(0xFFFFF8D6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.qr_code_2_rounded, color: Color(0xFF7A6800), size: 24),
                              SizedBox(width: 10),
                              Text(
                                'Mi Código de Socio',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF2C2200),
                                  fontFamily: 'Plus Jakarta Sans',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Comparte este código con tu socio o conductor para vincular notificaciones:',
                            style: TextStyle(fontSize: 12, color: Color(0xFF7A6800)),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFFFCD19)),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  code,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2,
                                    color: Color(0xFF2C2200),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.copy_rounded, color: Color(0xFF7A6800)),
                                  tooltip: 'Copiar Código',
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: code));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Código copiado al portapapeles')),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.person_add_alt_1_rounded, size: 20),
                              label: const Text('Ingresar Código o Buscar Socio'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFCD19),
                                foregroundColor: const Color(0xFF2C2200),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const AddLinkScreen()),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 28),

                // --- SOLICITUDES PENDIENTES ---
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, authState) {
                    final currentUserId = authState.userProfile?.id;
                    final pendingRequests = state.linkRequests?.where((req) {
                      final isPending = req.status.toLowerCase() == 'pending';
                      final isReceiver = req.receiverId == currentUserId;
                      return isPending && isReceiver;
                    }).toList() ?? [];

                    if (pendingRequests.isEmpty) return const SizedBox.shrink();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Solicitudes Pendientes',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 16),
                        ...pendingRequests.map((request) {
                          final user = request.sender ?? {'name': 'Usuario'};
                          return SoftCard(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(user['name'] ?? 'Usuario',
                                          style: const TextStyle(fontWeight: FontWeight.bold)),
                                      if (user['email'] != null) Text(user['email'], style: const TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.check_circle_rounded, color: AppTheme.successColor),
                                  onPressed: () {
                                    context.read<NotificationBloc>().add(AcceptLinkRequest(request.id));
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.cancel_rounded, color: AppTheme.errorColor),
                                  onPressed: () {
                                    context.read<NotificationBloc>().add(RejectLinkRequest(request.id));
                                  },
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 32),
                      ],
                    );
                  },
                ),

                // --- VINCULACIONES ACTIVAS ---
                Text(
                  'Vinculaciones Activas',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 16),
                if (state.linkedUsers == null || state.linkedUsers!.isEmpty)
                  const Center(child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text('No tienes socios vinculados aún.', style: TextStyle(color: AppTheme.textPlaceholder)),
                  )),
                if (state.linkedUsers != null && state.linkedUsers!.isNotEmpty)
                  ...state.linkedUsers!.map((link) {
                    final authBloc = context.read<AuthBloc>();
                    final currentUserId = authBloc.state.userProfile?.id;
                    final isSource = link.sourceId == currentUserId;
                    final otherUser = isSource ? (link.target ?? {}) : (link.source ?? {});

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SoftCard(
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(otherUser['name'] ?? 'Usuario Socio', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  if (otherUser['email'] != null) Text(otherUser['email'], style: const TextStyle(fontSize: 12)),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: link.status == 'active' ? AppTheme.successColor.withValues(alpha: 0.1) : AppTheme.textPlaceholder.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          link.status == 'active' ? 'ACTIVO' : 'SUSPENDIDO', 
                                          style: TextStyle(color: link.status == 'active' ? AppTheme.successColor : AppTheme.textPlaceholder, fontSize: 10, fontWeight: FontWeight.bold)
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Socio desde: ${_formatDate(link.linkedAt)}',
                                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert_rounded),
                              onSelected: (value) {
                                if (value == 'suspend') {
                                  context.read<NotificationBloc>().add(UpdateLink(linkId: link.id, status: 'suspended'));
                                } else if (value == 'activate') {
                                  context.read<NotificationBloc>().add(UpdateLink(linkId: link.id, status: 'active'));
                                } else if (value == 'delete') {
                                  _showDeleteConfirmDialog(context, link);
                                }
                              },
                              itemBuilder: (context) => [
                                if (link.status == 'active')
                                  const PopupMenuItem(
                                    value: 'suspend',
                                    child: Text('Suspender'),
                                  ),
                                if (link.status != 'active')
                                  const PopupMenuItem(
                                    value: 'activate',
                                    child: Text('Reactivar'),
                                  ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Eliminar vinculación', style: TextStyle(color: AppTheme.errorColor)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            );
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showDeleteConfirmDialog(BuildContext context, UserLink link) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Eliminar vinculación', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('¿Está seguro de que desea eliminar esta vinculación? Ya no recibirán tus notificaciones.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          AppButton(
            label: 'Eliminar',
            color: AppTheme.errorColor,
            onPressed: () {
              context.read<NotificationBloc>().add(DeleteLink(link.id));
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
