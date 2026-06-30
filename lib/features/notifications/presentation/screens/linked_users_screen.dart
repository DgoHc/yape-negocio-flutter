
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/yt_design_system.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
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
      appBar: AppBar(title: const Text('Usuarios Vinculados')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddLinkScreen()),
          );
        },
        backgroundColor: const Color(0xFF00BFA5),
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: YtLoader());
            }

            if (state.errorMessage != null) {
              return Text(
                state.errorMessage!,
                style: const TextStyle(color: Colors.red),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Show pending link requests
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
                        const Text(
                          'Solicitudes Pendientes',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        ...pendingRequests.map((request) {
                          final user = request.sender ?? {'name': 'Usuario'};
                          return YtCard(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(user['name'] ?? 'Usuario',
                                          style: const TextStyle(fontWeight: FontWeight.bold)),
                                      if (user['email'] != null) Text(user['email']),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.check, color: Colors.green),
                                  onPressed: () {
                                    context.read<NotificationBloc>().add(AcceptLinkRequest(request.id));
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.red),
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

                // Show linked users
                const Text(
                  'Vinculaciones',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                if (state.linkedUsers == null || state.linkedUsers!.isEmpty)
                  const Center(child: Text('No hay usuarios vinculados')),
                if (state.linkedUsers != null && state.linkedUsers!.isNotEmpty)
                  ...state.linkedUsers!.map((link) {
                    final authBloc = context.read<AuthBloc>();
                    final currentUserId = authBloc.state.userProfile?.id;
                    final isSource = link.sourceId == currentUserId;
                    final otherUser = isSource ? (link.target ?? {}) : (link.source ?? {});

                    return YtCard(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(otherUser['name'] ?? 'Usuario', style: const TextStyle(fontWeight: FontWeight.bold)),
                                if (otherUser['email'] != null) Text(otherUser['email']),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    if (link.status == 'active')
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text('Activo', style: TextStyle(color: Colors.green, fontSize: 12)),
                                      ),
                                    if (link.status != 'active')
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text('Suspendido', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                      ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Vinculado: ${_formatDate(link.linkedAt)}',
                                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
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
                                child: Text('Eliminar vinculación'),
                              ),
                            ],
                          ),
                        ],
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
        title: const Text('Eliminar vinculación'),
        content: const Text('¿Está seguro de que desea eliminar esta vinculación?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<NotificationBloc>().add(DeleteLink(link.id));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
