import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/yt_design_system.dart';
import '../../../auth/domain/entities/user_profile.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/admin_bloc.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final isSuperAdmin = authState.userRole == 'SUPER_ADMIN';
    final isAdmin = authState.userRole == 'ADMIN';
    
    return BlocProvider(
      create: (context) {
        final bloc = sl<AdminBloc>()..add(LoadDevices());
        if (isSuperAdmin || isAdmin) {
          bloc.add(LoadUserProfiles());
        }
        if (isSuperAdmin) {
          bloc.add(LoadUsers());
        }
        return bloc;
      },
      child: const AdminPanelView(),
    );
  }
}

class AdminPanelView extends StatelessWidget {
  const AdminPanelView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final isSuperAdmin = authState.userRole == 'SUPER_ADMIN';
        final isAdmin = authState.userRole == 'ADMIN';
        final canSeeProfiles = isSuperAdmin || isAdmin;

        return DefaultTabController(
          length: isSuperAdmin ? 3 : (isAdmin ? 2 : 1),
          child: MultiBlocListener(
            listeners: [
              BlocListener<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state.status == AuthStatus.initial || 
                      state.status == AuthStatus.unauthenticated) {
                    context.go('/login');
                  }
                },
              ),
              BlocListener<AdminBloc, AdminState>(
                listener: (context, state) {
                  if (state.status == AdminStatus.failure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.error ?? 'Error desconocido'), backgroundColor: Colors.red),
                    );
                  } else if (state.status == AdminStatus.success && state.message != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message!), backgroundColor: Colors.green),
                    );
                  }
                },
              ),
            ],
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Panel de Administración'),
                bottom: canSeeProfiles
                    ? TabBar(
                        tabs: [
                          const Tab(icon: Icon(Icons.devices), text: 'Dispositivos'),
                          if (isSuperAdmin) const Tab(icon: Icon(Icons.people), text: 'Usuarios'),
                          const Tab(icon: Icon(Icons.person_pin), text: 'Perfiles'),
                        ],
                      )
                    : null,
                actions: [
                  BlocBuilder<AdminBloc, AdminState>(
                    builder: (context, state) {
                      return IconButton(
                        icon: state.status == AdminStatus.exporting 
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.download),
                        onPressed: state.status == AdminStatus.exporting 
                          ? null 
                          : () => context.read<AdminBloc>().add(ExportAdminDataRequested()),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      context.read<AdminBloc>().add(LoadDevices());
                      if (canSeeProfiles) {
                        context.read<AdminBloc>().add(LoadUserProfiles());
                      }
                      if (isSuperAdmin) {
                        context.read<AdminBloc>().add(LoadUsers());
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () {
                      context.read<AuthBloc>().add(LogoutRequested());
                    },
                  ),
                ],
              ),
              body: TabBarView(
                children: [
                  _buildDevicesTab(context, isSuperAdmin || isAdmin),
                  if (isSuperAdmin) _buildUsersTab(context),
                  if (canSeeProfiles) _buildUserProfilesTab(context),
                ],
              ),
              floatingActionButton: Builder(
                builder: (builderContext) => _buildFab(builderContext, authState),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDevicesTab(BuildContext context, bool isSuperAdmin) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gestión de Conductores',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<AdminBloc, AdminState>(
              builder: (context, state) {
                if (state.status == AdminStatus.loading && state.devices.isEmpty) {
                  return const Center(child: YtLoader());
                }

                if (state.devices.isEmpty) {
                  return const Center(
                    child: Text('No hay dispositivos registrados'),
                  );
                }

                return ListView.builder(
                  itemCount: state.devices.length,
                  itemBuilder: (context, index) {
                    final device = state.devices[index];
                    return _buildDeviceItem(context, device, isSuperAdmin);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gestión de Administradores y Supervisores',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<AdminBloc, AdminState>(
              builder: (context, state) {
                if (state.status == AdminStatus.loading && state.users.isEmpty) {
                  return const Center(child: YtLoader());
                }

                if (state.users.isEmpty) {
                  return const Center(
                    child: Text('No hay usuarios registrados'),
                  );
                }

                return ListView.builder(
                  itemCount: state.users.length,
                  itemBuilder: (context, index) {
                    final user = state.users[index];
                    return _buildUserItem(context, user);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfilesTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gestión de Perfiles de Usuarios',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<AdminBloc, AdminState>(
              builder: (context, state) {
                if (state.status == AdminStatus.loading && state.userProfiles.isEmpty) {
                  return const Center(child: YtLoader());
                }

                if (state.userProfiles.isEmpty) {
                  return const Center(
                    child: Text('No hay perfiles de usuario registrados'),
                  );
                }

                return ListView.builder(
                  itemCount: state.userProfiles.length,
                  itemBuilder: (context, index) {
                    final profile = state.userProfiles[index];
                    return _buildUserProfileItem(context, profile);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfileItem(BuildContext context, UserProfile profile) {
    // Check if profile has access
    final hasAccess = profile.isSubscribed ||
        (profile.trialEndDate != null &&
            profile.trialEndDate!.isAfter(DateTime.now()));

    return YtCard(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: Icon(
          hasAccess ? Icons.check_circle : Icons.cancel,
          color: hasAccess ? Colors.green : Colors.red,
        ),
        title: Text(profile.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (profile.email != null) Text('Email: ${profile.email}'),
            if (profile.phone != null) Text('Teléfono: ${profile.phone}'),
            if (profile.uuid != null) Text('UUID: ${profile.uuid}'),
            Text(
              'Estado: ${hasAccess ? "Activo" : "Sin acceso"}',
            ),
          ],
        ),
        trailing: profile.id == null 
          ? null 
          : Switch(
              value: profile.isSubscribed,
              onChanged: (newValue) {
                context.read<AdminBloc>().add(UpdateUserProfileSubscription(
                      id: profile.id!,
                      isSubscribed: newValue,
                    ));
              },
            ),
      ),
    );
  }

  Widget _buildFab(BuildContext context, AuthState authState) {
    if (authState.userRole == 'SUPER_ADMIN') {
      return FloatingActionButton(
        backgroundColor: const Color(0xFF7C4DFF),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          final tabIndex = DefaultTabController.of(context).index;
          if (tabIndex == 0) {
            _showAddDeviceDialog(context);
          } else {
            _showAddUserDialog(context);
          }
        },
      );
    } else if (authState.userRole == 'ADMIN') {
      return FloatingActionButton(
        backgroundColor: const Color(0xFF7C4DFF),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showAddDeviceDialog(context),
      );
    }
    return const SizedBox.shrink();
  }

  void _showAddUserDialog(BuildContext context) {
    final usernameController = TextEditingController();
    final pinController = TextEditingController();
    String selectedRole = 'ADMIN';

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (statefulContext, setState) => AlertDialog(
          title: const Text('Crear Usuario Administrativo'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                YtTextField(
                  controller: usernameController,
                  label: 'Nombre de Usuario',
                  hintText: 'Ej. admin_central',
                ),
                const SizedBox(height: 16),
                YtTextField(
                  controller: pinController,
                  label: 'PIN (6 dígitos)',
                  hintText: '000000',
                  keyboardType: TextInputType.number,
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedRole,
                  decoration: const InputDecoration(labelText: 'Rol'),
                  items: const [
                    DropdownMenuItem(value: 'ADMIN', child: Text('Administrador')),
                    DropdownMenuItem(value: 'SUPERVISOR', child: Text('Supervisor')),
                    DropdownMenuItem(value: 'SUPER_ADMIN', child: Text('Super Admin')),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => selectedRole = value);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (usernameController.text.isNotEmpty && pinController.text.length == 6) {
                  context.read<AdminBloc>().add(CreateUserRequested(
                        username: usernameController.text,
                        pin: pinController.text,
                        role: selectedRole,
                      ));
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Crear'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDeviceDialog(BuildContext context) {
    final uuidController = TextEditingController();
    final aliasController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Registrar Conductor'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              YtTextField(
                controller: uuidController,
                label: 'UUID del Dispositivo',
                hintText: 'XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX',
              ),
              const SizedBox(height: 16),
              YtTextField(
                controller: aliasController,
                label: 'Alias / Nombre Unidad',
                hintText: 'Ej. Unidad 05',
              ),
              const SizedBox(height: 16),
              YtTextField(
                controller: phoneController,
                label: 'Número de Teléfono (Opcional)',
                hintText: '9XXXXXXXX',
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (uuidController.text.isNotEmpty && aliasController.text.isNotEmpty) {
                context.read<AdminBloc>().add(RegisterDeviceManual(
                      uuid: uuidController.text,
                      alias: aliasController.text,
                      phoneNumber: phoneController.text.isEmpty ? null : phoneController.text,
                    ));
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Registrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceItem(BuildContext context, Map<String, dynamic> device, bool isSuperAdmin) {
    final bool isApproved = device['isApproved'] ?? false;
    final String status = device['status'] ?? 'ACTIVE';
    final String uuid = device['uuid'] ?? 'Sin ID';
    final String id = device['id'].toString();

    return YtCard(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(
          status == 'ACTIVE' ? Icons.check_circle : Icons.error,
          color: status == 'ACTIVE' ? (isApproved ? Colors.green : Colors.orange) : Colors.red,
        ),
        title: Text(device['alias'] ?? 'Dispositivo Desconocido'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('UUID: $uuid'),
            Text('Estado: ${status == 'ACTIVE' ? (isApproved ? 'Aprobado' : 'Pendiente') : 'Suspendido'}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'approve') {
              context.read<AdminBloc>().add(UpdateDeviceStatus(id: id, isApproved: !isApproved));
            } else if (value == 'suspend') {
              context.read<AdminBloc>().add(UpdateDeviceStatus(id: id, status: status == 'ACTIVE' ? 'SUSPENDED' : 'ACTIVE'));
            } else if (value == 'delete' && isSuperAdmin) {
              context.read<AdminBloc>().add(DeleteDeviceRequested(id));
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'approve',
              child: Text(isApproved ? 'Quitar Aprobación' : 'Aprobar'),
            ),
            PopupMenuItem(
              value: 'suspend',
              child: Text(status == 'ACTIVE' ? 'Suspender' : 'Reactivar'),
            ),
            if (isSuperAdmin)
              const PopupMenuItem(
                value: 'delete',
                child: Text('Eliminar', style: TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserItem(BuildContext context, Map<String, dynamic> user) {
    final String status = user['status'] ?? 'ACTIVE';
    final String role = user['role'] ?? 'ADMIN';
    final String id = user['id'].toString();

    return YtCard(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(
          role == 'SUPER_ADMIN' ? Icons.security : Icons.person,
          color: status == 'ACTIVE' ? Colors.blue : Colors.red,
        ),
        title: Text(user['username'] ?? 'Usuario'),
        subtitle: Text('Rol: $role | Estado: $status'),
        trailing: role == 'SUPER_ADMIN'
            ? null
            : PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'status') {
                    context.read<AdminBloc>().add(UpdateUserStatus(id: id, status: status == 'ACTIVE' ? 'SUSPENDED' : 'ACTIVE'));
                  } else if (value == 'role') {
                    context.read<AdminBloc>().add(UpdateUserStatus(id: id, role: role == 'ADMIN' ? 'SUPERVISOR' : 'ADMIN'));
                  } else if (value == 'delete') {
                    context.read<AdminBloc>().add(DeleteUserRequested(id));
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'status',
                    child: Text(status == 'ACTIVE' ? 'Suspender' : 'Reactivar'),
                  ),
                  PopupMenuItem(
                    value: 'role',
                    child: Text('Cambiar a ${role == 'ADMIN' ? 'Supervisor' : 'Administrador'}'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Eliminar', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
      ),
    );
  }
}
