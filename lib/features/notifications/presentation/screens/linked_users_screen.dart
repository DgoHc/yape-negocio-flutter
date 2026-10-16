import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/yt_design_system.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/notification_link_entities.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';

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

class LinkedUsersView extends StatefulWidget {
  const LinkedUsersView({super.key});

  @override
  State<LinkedUsersView> createState() => _LinkedUsersViewState();
}

class _LinkedUsersViewState extends State<LinkedUsersView> {
  final _searchController = TextEditingController();
  final _codeController = TextEditingController();
  String _searchQuery = '';
  bool _isScanning = false;
  bool _showCodeInput = false;

  @override
  void dispose() {
    _searchController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Usuarios Vinculados'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF2C2200)),
            tooltip: 'Actualizar lista',
            onPressed: () {
              context.read<NotificationBloc>().add(GetLinkRequests());
              context.read<NotificationBloc>().add(GetLinkedUsers());
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _showCodeInput = !_showCodeInput),
        backgroundColor: const Color(0xFFFFCD19),
        child: const Icon(Icons.person_add_alt_1_rounded, color: Color(0xFF2C2200)),
      ),
      body: BlocConsumer<NotificationBloc, NotificationState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!), backgroundColor: AppTheme.errorColor),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading && (state.linkedUsers == null && state.linkRequests == null)) {
            return const Center(child: YtLoader());
          }

          final authBloc = context.read<AuthBloc>();
          final profile = authBloc.state.userProfile;
          final currentUserId = profile?.id;
          final currentUserUuid = profile?.uuid;
          final currentUserEmail = profile?.email?.toLowerCase();

          final activeLinks = state.linkedUsers ?? [];
          
          final filteredLinks = activeLinks.where((link) {
            if (_searchQuery.isEmpty) return true;
            final isSource = link.sourceId == currentUserId || (currentUserUuid != null && link.sourceId == currentUserUuid);
            final otherUser = isSource ? (link.target ?? {}) : (link.source ?? {});
            final name = (otherUser['name'] ?? '').toString().toLowerCase();
            final email = (otherUser['email'] ?? '').toString().toLowerCase();
            final query = _searchQuery.toLowerCase();
            return name.contains(query) || email.contains(query);
          }).toList();

          // Solicitudes Recibidas (Para Aceptar o Rechazar)
          final receivedRequests = state.linkRequests?.where((req) {
            final isPending = req.status.toLowerCase() == 'pending';
            final isReceiver = (req.receiverId == currentUserId) ||
                               (currentUserUuid != null && req.receiverId == currentUserUuid) ||
                               (currentUserEmail != null && req.receiver?['email']?.toString().toLowerCase() == currentUserEmail) ||
                               (req.receiver?['id']?.toString() == currentUserId);
            return isPending && isReceiver;
          }).toList() ?? [];

          // Solicitudes Enviadas (Esperando respuesta del socio)
          final sentRequests = state.linkRequests?.where((req) {
            final isPending = req.status.toLowerCase() == 'pending';
            final isSender = (req.senderId == currentUserId) ||
                             (currentUserUuid != null && req.senderId == currentUserUuid) ||
                             (currentUserEmail != null && req.sender?['email']?.toString().toLowerCase() == currentUserEmail) ||
                             (req.sender?['id']?.toString() == currentUserId);
            return isPending && isSender;
          }).toList() ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. BUSCADOR DE SOCIOS
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE8E9F3), width: 1.2),
                    boxShadow: AppTheme.softProShadow(intensity: 0.3),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val.trim()),
                    decoration: const InputDecoration(
                      hintText: 'Buscar socio por Nombre, Apellido o Código...',
                      hintStyle: TextStyle(fontSize: 13, color: AppTheme.textPlaceholder),
                      prefixIcon: Icon(Icons.search_rounded, color: Color(0xFFFFCD19)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                  ),
                ),

                if (_searchQuery.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  SoftCard(
                    color: const Color(0xFFFFF8D6),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Color(0xFFFFCD19),
                          child: Icon(Icons.person_search_rounded, color: Color(0xFF2C2200), size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _searchQuery,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Text('Vincular con este socio', style: TextStyle(fontSize: 11, color: Color(0xFF7A6800))),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFCD19),
                            foregroundColor: const Color(0xFF2C2200),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                          ),
                          onPressed: () {
                            context.read<NotificationBloc>().add(SendLinkRequest(_searchQuery));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Solicitud enviada a "$_searchQuery"'), backgroundColor: AppTheme.successColor),
                            );
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                          child: const Text('Vincular', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // 2. DESPLEGABLE PARA VINCULAR VÍA CÓDIGO O ESCANEAR QR
                SoftCard(
                  color: const Color(0xFFFFF8D6),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () => setState(() => _showCodeInput = !_showCodeInput),
                        borderRadius: BorderRadius.circular(16),
                        child: Row(
                          children: [
                            const Icon(Icons.person_add_rounded, color: Color(0xFF7A6800), size: 22),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Ingresar Código de Socio o Escanear QR',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF2C2200),
                                  fontFamily: 'Plus Jakarta Sans',
                                ),
                              ),
                            ),
                            Icon(
                              _showCodeInput ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                              color: const Color(0xFF7A6800),
                            ),
                          ],
                        ),
                      ),

                      if (_showCodeInput) ...[
                        const SizedBox(height: 16),
                        const Divider(height: 1, color: Color(0xFFFFE082)),
                        const SizedBox(height: 16),
                        YtTextField(
                          controller: _codeController,
                          label: 'Código de Socio',
                          hintText: 'Ej. SONO-8899',
                          prefixIcon: Icons.qr_code_rounded,
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: AppButton(
                                label: 'Enviar Solicitud',
                                isLoading: state.isLoading,
                                onPressed: () {
                                  if (_codeController.text.isNotEmpty) {
                                    context.read<NotificationBloc>().add(SendLinkRequest(_codeController.text.trim()));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Solicitud enviada a "${_codeController.text.trim()}"'), backgroundColor: AppTheme.successColor),
                                    );
                                    _codeController.clear();
                                    setState(() => _showCodeInput = false);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            IconButton(
                              icon: const Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF2C2200), size: 28),
                              tooltip: 'Escanear QR',
                              onPressed: _isScanning ? null : _openQrScanner,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // 3. SOLICITUDES RECIBIDAS (PARA ACEPTAR / RECHAZAR)
                if (receivedRequests.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(Icons.mark_email_unread_rounded, color: Color(0xFFFFCD19), size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'Solicitudes Recibidas (${receivedRequests.length})',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  for (final request in receivedRequests)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: SoftCard(
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(request.sender?['name'] ?? 'Socio', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  if (request.sender?['email'] != null) Text(request.sender!['email'], style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.successColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                              ),
                              icon: const Icon(Icons.check_rounded, size: 16),
                              label: const Text('Aceptar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              onPressed: () {
                                context.read<NotificationBloc>().add(AcceptLinkRequest(request.id));
                              },
                            ),
                            const SizedBox(width: 6),
                            IconButton(
                              icon: const Icon(Icons.cancel_rounded, color: AppTheme.errorColor),
                              onPressed: () {
                                context.read<NotificationBloc>().add(RejectLinkRequest(request.id));
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 28),
                ],

                // 4. SOLICITUDES ENVIADAS (PENDIENTES DE RESPUESTA)
                if (sentRequests.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(Icons.outbox_rounded, color: Color(0xFF7A6800), size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'Solicitudes Enviadas (${sentRequests.length})',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  for (final request in sentRequests)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: SoftCard(
                        color: const Color(0xFFFAFAFA),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(request.receiver?['name'] ?? 'Socio Destino', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const Text('Esperando que el socio acepte...', style: TextStyle(fontSize: 11, color: Color(0xFF7A6800))),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF8D6),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: const Text('PENDIENTE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF7A6800))),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 28),
                ],

                // 5. VINCULACIONES ACTIVAS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Socios Vinculados',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    Text(
                      '${filteredLinks.length} activos',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF7A6800), fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                if (filteredLinks.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('No hay socios vinculados que coincidan.', style: TextStyle(color: AppTheme.textPlaceholder)),
                    ),
                  )
                else
                  for (final link in filteredLinks)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildUserCard(context, link, currentUserId, currentUserUuid),
                    ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, UserLink link, String? currentUserId, String? currentUserUuid) {
    final isSource = link.sourceId == currentUserId || (currentUserUuid != null && link.sourceId == currentUserUuid);
    final otherUser = isSource ? (link.target ?? {}) : (link.source ?? {});

    return SoftCard(
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
                        style: TextStyle(color: link.status == 'active' ? AppTheme.successColor : AppTheme.textPlaceholder, fontSize: 10, fontWeight: FontWeight.bold),
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
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _openQrScanner() async {
    setState(() => _isScanning = true);
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(color: Colors.black, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: MobileScanner(
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                _codeController.text = barcodes.first.rawValue!;
                Navigator.pop(context);
              }
            },
          ),
        ),
      ),
    );
    setState(() => _isScanning = false);
  }

  void _showDeleteConfirmDialog(BuildContext context, UserLink link) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Eliminar vinculación', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('¿Está seguro de que desea eliminar esta vinculación? Ya no recibirán tus notificaciones.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          AppButton(
            label: 'Eliminar',
            color: AppTheme.errorColor,
            onPressed: () {
              context.read<NotificationBloc>().add(DeleteLink(link.id));
              Navigator.pop(dialogContext);
            },
          ),
        ],
      ),
    );
  }
}
