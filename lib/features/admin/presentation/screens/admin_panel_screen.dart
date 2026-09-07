import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/yt_design_system.dart';
import '../../../../core/theme/app_theme.dart';
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
                      SnackBar(content: Text(state.error ?? 'Error desconocido'), backgroundColor: AppTheme.errorColor),
                    );
                  } else if (state.status == AdminStatus.success && state.message != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message!), backgroundColor: AppTheme.successColor),
                    );
                  }
                },
              ),
            ],
            child: Scaffold(
              backgroundColor: AppTheme.backgroundColor,
              appBar: AppBar(
                title: const Text('Panel Administrativo'),
                bottom: canSeeProfiles
                    ? TabBar(
                        indicatorColor: AppTheme.primaryColor,
                        labelColor: AppTheme.textPrimary,
                        tabs: [
                          const Tab(icon: Icon(Icons.devices_rounded), text: 'Equipos'),
                          if (isSuperAdmin) const Tab(icon: Icon(Icons.people_alt_rounded), text: 'Admins'),
                          const Tab(icon: Icon(Icons.person_search_rounded), text: 'Perfiles'),
                        ],
                      )
                    : null,
                actions: [
                  BlocBuilder<AdminBloc, AdminState>(
                    builder: (context, state) {
                      return IconButton(
                        icon: state.status == AdminStatus.exporting 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryColor))
                          : const Icon(Icons.download_rounded),
                        onPressed: state.status == AdminStatus.exporting 
                          ? null 
                          : () => context.read<AdminBloc>().add(ExportAdminDataRequested()),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout_rounded),
                    onPressed: () => context.read<AuthBloc>().add(const LogoutRequested()),
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
    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        if (state.status == AdminStatus.loading && state.devices.isEmpty) {
          return const Center(child: YtLoader());
        }

        if (state.devices.isEmpty) {
          return const Center(child: Text('No hay dispositivos registrados'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: state.devices.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final device = state.devices[index];
            return _buildDeviceItem(context, device, isSuperAdmin);
          },
        );
      },
    );
  }

  Widget _buildUsersTab(BuildContext context) {
    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        if (state.status == AdminStatus.loading && state.users.isEmpty) {
          return const Center(child: YtLoader());
        }

        if (state.users.isEmpty) {
          return const Center(child: Text('No hay usuarios administrativos'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: state.users.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final user = state.users[index];
            return _buildUserItem(context, user);
          },
        );
      },
    );
  }

  Widget _buildUserProfilesTab(BuildContext context) {
    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        if (state.status == AdminStatus.loading && state.userProfiles.isEmpty) {
          return const Center(child: YtLoader());
        }

        if (state.userProfiles.isEmpty) {
          return const Center(child: Text('No hay perfiles de usuario'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: state.userProfiles.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final profile = state.userProfiles[index];
            return _buildUserProfileItem(context, profile);
          },
        );
      },
    );
  }

  Widget _buildUserProfileItem(BuildContext context, UserProfile profile) {
    final hasAccess = profile.isSubscribed ||
        (profile.trialEndDate != null &&
            profile.trialEndDate!.isAfter(DateTime.now()));

    return SoftCard(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: ClayContainer(
          width: 40, height: 40, borderRadius: 10,
          color: hasAccess ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
          child: Icon(
            hasAccess ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: hasAccess ? AppTheme.successColor : AppTheme.errorColor,
            size: 20,
          ),
        ),
        title: Text(profile.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (profile.email != null) Text(profile.email!, style: const TextStyle(fontSize: 11)),
            Text('Estado: ${hasAccess ? "ACTIVO" : "SIN ACCESO"}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
        trailing: profile.id == null 
          ? null 
          : Switch(
              activeColor: AppTheme.primaryColor,
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
    return FloatingActionButton(
      backgroundColor: AppTheme.primaryColor,
      child: const Icon(Icons.add_rounded, color: Color(0xFF3D2E00)),
      onPressed: () {
        final tabIndex = DefaultTabController.of(context).index;
        if (tabIndex == 0) {
          _showAddDeviceDialog(context);
        } else if (tabIndex == 1 && authState.userRole == 'SUPER_ADMIN') {
          _showAddUserDialog(context);
        }
      },
    );
  }

  void _showAddUserDialog(BuildContext context) {
    final usernameController = TextEditingController();
    final pinController = TextEditingController();
    String selectedRole = 'ADMIN';

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (statefulContext, setState) => AlertDialog(
          backgroundColor: AppTheme.backgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: const Text('Nuevo Administrador', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                YtTextField(controller: usernameController, label: 'Usuario', hintText: 'Ej. admin_01'),
                const SizedBox(height: 16),
                YtTextField(controller: pinController, label: 'PIN (6 dígitos)', hintText: '000000', keyboardType: TextInputType.number, obscureText: true),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                  child: Text('Rol de Acceso', style: Theme.of(context).textTheme.labelMedium),
                ),
                ClayContainer(
                  color: AppTheme.surfaceColor, borderRadius: 16, isPressed: true, shadowIntensity: 0.3,
                  child: DropdownButtonFormField<String>(
                    initialValue: selectedRole,
                    decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 20)),
                    items: const [
                      DropdownMenuItem(value: 'ADMIN', child: Text('Administrador')),
                      DropdownMenuItem(value: 'SUPERVISOR', child: Text('Supervisor')),
                      DropdownMenuItem(value: 'SUPER_ADMIN', child: Text('Super Admin')),
                    ],
                    onChanged: (value) => setState(() => selectedRole = value!),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
            AppButton(label: 'Crear', onPressed: () {
              if (usernameController.text.isNotEmpty && pinController.text.length == 6) {
                context.read<AdminBloc>().add(CreateUserRequested(username: usernameController.text, pin: pinController.text, role: selectedRole));
                Navigator.pop(dialogContext);
              }
            }),
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
        backgroundColor: AppTheme.backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Registrar Conductor', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              YtTextField(controller: uuidController, label: 'UUID Dispositivo', hintText: 'XXXXXXXX-...'),
              const SizedBox(height: 16),
              YtTextField(controller: aliasController, label: 'Alias Unidad', hintText: 'Ej. Taxi 05'),
              const SizedBox(height: 16),
              YtTextField(controller: phoneController, label: 'Celular (Opcional)', hintText: '9XXXXXXXX', keyboardType: TextInputType.phone),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
          AppButton(label: 'Registrar', onPressed: () {
            if (uuidController.text.isNotEmpty && aliasController.text.isNotEmpty) {
              context.read<AdminBloc>().add(RegisterDeviceManual(uuid: uuidController.text, alias: aliasController.text, phoneNumber: phoneController.text.isEmpty ? null : phoneController.text));
              Navigator.pop(dialogContext);
            }
          }),
        ],
      ),
    );
  }

  Widget _buildDeviceItem(BuildContext context, Map<String, dynamic> device, bool isSuperAdmin) {
    final bool isApproved = device['isApproved'] ?? false;
    final String status = device['status'] ?? 'ACTIVE';
    final String id = device['id'].toString();

    return SoftCard(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: ClayContainer(
          width: 40, height: 40, borderRadius: 10,
          color: status == 'ACTIVE' ? (isApproved ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0)) : const Color(0xFFFFEBEE),
          child: Icon(
            status == 'ACTIVE' ? Icons.local_taxi_rounded : Icons.block_rounded,
            color: status == 'ACTIVE' ? (isApproved ? AppTheme.successColor : Colors.orange) : AppTheme.errorColor,
            size: 20,
          ),
        ),
        title: Text(device['alias'] ?? 'Unidad', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Estado: ${status == 'ACTIVE' ? (isApproved ? 'Aprobado' : 'Pendiente') : 'Suspendido'}', style: const TextStyle(fontSize: 10)),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_horiz_rounded),
          onSelected: (value) {
            if (value == 'approve') context.read<AdminBloc>().add(UpdateDeviceStatus(id: id, isApproved: !isApproved));
            else if (value == 'suspend') context.read<AdminBloc>().add(UpdateDeviceStatus(id: id, status: status == 'ACTIVE' ? 'SUSPENDED' : 'ACTIVE'));
            else if (value == 'delete' && isSuperAdmin) context.read<AdminBloc>().add(DeleteDeviceRequested(id));
          },
          itemBuilder: (context) => [
            PopupMenuItem(value: 'approve', child: Text(isApproved ? 'Quitar Aprobación' : 'Aprobar')),
            PopupMenuItem(value: 'suspend', child: Text(status == 'ACTIVE' ? 'Suspender' : 'Reactivar')),
            if (isSuperAdmin) const PopupMenuItem(value: 'delete', child: Text('Eliminar', style: TextStyle(color: AppTheme.errorColor))),
          ],
        ),
      ),
    );
  }

  Widget _buildUserItem(BuildContext context, Map<String, dynamic> user) {
    final String status = user['status'] ?? 'ACTIVE';
    final String role = user['role'] ?? 'ADMIN';
    final String id = user['id'].toString();

    return SoftCard(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: Icon(role == 'SUPER_ADMIN' ? Icons.admin_panel_settings_rounded : Icons.person_rounded, color: status == 'ACTIVE' ? Colors.blue : AppTheme.errorColor),
        title: Text(user['username'] ?? 'Admin', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Rol: $role | $status', style: const TextStyle(fontSize: 10)),
        trailing: role == 'SUPER_ADMIN' ? null : PopupMenuButton<String>(
          icon: const Icon(Icons.settings_rounded, size: 18),
          onSelected: (value) {
            if (value == 'status') context.read<AdminBloc>().add(UpdateUserStatus(id: id, status: status == 'ACTIVE' ? 'SUSPENDED' : 'ACTIVE'));
            else if (value == 'role') context.read<AdminBloc>().add(UpdateUserStatus(id: id, role: role == 'ADMIN' ? 'SUPERVISOR' : 'ADMIN'));
            else if (value == 'delete') context.read<AdminBloc>().add(DeleteUserRequested(id));
          },
          itemBuilder: (context) => [
            PopupMenuItem(value: 'status', child: Text(status == 'ACTIVE' ? 'Suspender' : 'Reactivar')),
            PopupMenuItem(value: 'role', child: Text('Cambiar a ${role == 'ADMIN' ? 'Supervisor' : 'Admin'}')),
            const PopupMenuItem(value: 'delete', child: Text('Eliminar', style: TextStyle(color: AppTheme.errorColor))),
          ],
        ),
      ),
    );
  }
}
