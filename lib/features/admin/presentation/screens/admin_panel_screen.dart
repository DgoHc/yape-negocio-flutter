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
                  _buildDevicesTab(context, isSuperAdmin),
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
    String searchQuery = '';
    return StatefulBuilder(
      builder: (context, setState) {
        return BlocBuilder<AdminBloc, AdminState>(
          builder: (context, state) {
            if (state.status == AdminStatus.loading && state.userProfiles.isEmpty) {
              return const Center(child: YtLoader());
            }

            final filtered = state.userProfiles.where((p) {
              if (searchQuery.trim().isEmpty) return true;
              final q = searchQuery.toLowerCase();
              final nMatch = p.name.toLowerCase().contains(q);
              final eMatch = p.email?.toLowerCase().contains(q) ?? false;
              final pMatch = p.phone?.toLowerCase().contains(q) ?? false;
              return nMatch || eMatch || pMatch;
            }).toList();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE8E9F3)),
                    ),
                    child: TextField(
                      onChanged: (val) => setState(() => searchQuery = val),
                      decoration: const InputDecoration(
                        hintText: 'Buscar por Nombre y Apellido...',
                        hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                        prefixIcon: Icon(Icons.search_rounded, color: Color(0xFFFFCD19)),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(child: Text('No se encontraron perfiles'))
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final profile = filtered[index];
                            return _buildUserProfileItem(context, profile);
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildUserProfileItem(BuildContext context, UserProfile profile) {
    final hasAccess = profile.hasAccess;
    final expDateStr = profile.subscriptionEndDate != null
        ? '${profile.subscriptionEndDate!.day}/${profile.subscriptionEndDate!.month}/${profile.subscriptionEndDate!.year}'
        : null;

    return SoftCard(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: ClayContainer(
          width: 40, height: 40, borderRadius: 10,
          color: hasAccess ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
          child: Icon(
            hasAccess ? Icons.verified_user_rounded : Icons.person_off_rounded,
            color: hasAccess ? AppTheme.successColor : AppTheme.errorColor,
            size: 20,
          ),
        ),
        title: Text(profile.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (profile.email != null) Text(profile.email!, style: const TextStyle(fontSize: 11)),
            if (profile.businessType != null) Text('Rubro: ${profile.businessType}', style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
            Text(
              hasAccess
                  ? (expDateStr != null ? 'Suscripción Activa (Hasta: $expDateStr)' : 'Prueba / Suscripción Activa')
                  : 'Suscripción Inactiva / Suspendida',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: hasAccess ? AppTheme.successColor : AppTheme.errorColor,
              ),
            ),
          ],
        ),
        trailing: profile.id == null 
          ? null 
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  activeThumbColor: AppTheme.primaryColor,
                  value: profile.isSubscribed,
                  onChanged: (newValue) {
                    context.read<AdminBloc>().add(UpdateUserProfileSubscription(
                          id: profile.id!,
                          isSubscribed: newValue,
                        ));
                  },
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded),
                  onSelected: (value) {
                    if (value == 'manage_plan') {
                      _showManagePlanDialog(context, profile);
                    } else if (value == 'edit') {
                      _showEditAppUserDialog(context, profile);
                    } else if (value == 'delete') {
                      _confirmDeleteAppUser(context, profile);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'manage_plan',
                      child: Row(
                        children: [
                          Icon(Icons.card_membership_rounded, size: 18),
                          SizedBox(width: 8),
                          Text('Gestionar Plan / Días'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_rounded, size: 18),
                          SizedBox(width: 8),
                          Text('Editar Perfil'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_forever_rounded, size: 18, color: AppTheme.errorColor),
                          SizedBox(width: 8),
                          Text('Eliminar Perfil', style: TextStyle(color: AppTheme.errorColor)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
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
        } else {
          _showAddAppUserDialog(context);
        }
      },
    );
  }

  Widget _buildDeviceItem(BuildContext context, dynamic device, bool isSuperAdmin) {
    final id = device is Map ? (device['id']?.toString() ?? '') : (device.id?.toString() ?? '');
    final uuid = device is Map ? (device['uuid']?.toString() ?? '') : (device.uuid?.toString() ?? '');
    final alias = device is Map ? (device['alias']?.toString() ?? 'Sin alias') : (device.alias?.toString() ?? 'Sin alias');
    final isApproved = device is Map ? (device['isApproved'] == true) : (device.isApproved == true);

    return SoftCard(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: ClayContainer(
          width: 40, height: 40, borderRadius: 10,
          color: isApproved ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
          child: Icon(
            isApproved ? Icons.phone_android_rounded : Icons.no_cell_rounded,
            color: isApproved ? AppTheme.successColor : Colors.orange,
            size: 20,
          ),
        ),
        title: Text(alias, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('UUID: ${uuid.length > 16 ? "${uuid.substring(0, 16)}..." : uuid}', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
        trailing: isSuperAdmin
            ? Switch(
                activeThumbColor: AppTheme.primaryColor,
                value: isApproved,
                onChanged: (val) {
                  context.read<AdminBloc>().add(UpdateDeviceStatus(id: id, isApproved: val));
                },
              )
            : null,
      ),
    );
  }

  Widget _buildUserItem(BuildContext context, dynamic user) {
    final username = user is Map ? (user['username'] ?? user['name'] ?? user['email'] ?? 'Sin usuario') : (user.username ?? 'Sin usuario');
    final role = user is Map ? (user['role'] ?? 'ADMIN') : (user.role ?? 'ADMIN');

    return SoftCard(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: ClayContainer(
          width: 40, height: 40, borderRadius: 10,
          color: const Color(0xFFFFF8D6),
          child: const Icon(Icons.admin_panel_settings_rounded, color: Color(0xFF7A6800), size: 20),
        ),
        title: Text(username, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Rol: $role', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
      ),
    );
  }

  void _showManagePlanDialog(BuildContext context, UserProfile profile) {
    int selectedDays = 30;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (statefulContext, setState) => AlertDialog(
          backgroundColor: AppTheme.backgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: Text('Gestionar Plan - ${profile.name}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Selecciona la vigencia de la suscripción:', style: TextStyle(fontSize: 13)),
              const SizedBox(height: 12),
              RadioListTile<int>(
                title: const Text('1 Mes (30 Días)'),
                value: 30,
                groupValue: selectedDays,
                onChanged: (val) => setState(() => selectedDays = val!),
              ),
              RadioListTile<int>(
                title: const Text('3 Meses (90 Días)'),
                value: 90,
                groupValue: selectedDays,
                onChanged: (val) => setState(() => selectedDays = val!),
              ),
              RadioListTile<int>(
                title: const Text('Suscripción Completa / Ilimitada (1 Año)'),
                value: 365,
                groupValue: selectedDays,
                onChanged: (val) => setState(() => selectedDays = val!),
              ),
              RadioListTile<int>(
                title: const Text('Suscripción Máxima Premium (10 Años)'),
                value: 3650,
                groupValue: selectedDays,
                onChanged: (val) => setState(() => selectedDays = val!),
              ),
              RadioListTile<int>(
                title: const Text('Suspender Plan Ahora', style: TextStyle(color: AppTheme.errorColor, fontWeight: FontWeight.bold)),
                value: 0,
                groupValue: selectedDays,
                onChanged: (val) => setState(() => selectedDays = val!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
            AppButton(
              label: selectedDays == 0 ? 'Suspender' : 'Activar Plan',
              isSecondary: selectedDays == 0,
              onPressed: () {
                if (profile.id != null) {
                  final bool activate = selectedDays > 0;
                  context.read<AdminBloc>().add(
                        UpdateUserProfileSubscription(
                          id: profile.id!,
                          isSubscribed: activate,
                          days: activate ? selectedDays : null,
                        ),
                      );
                  Navigator.pop(dialogContext);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDeviceDialog(BuildContext context) {
    final uuidController = TextEditingController();
    final aliasController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.backgroundColor,
        title: const Text('Registrar Equipo Hardware'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            YtTextField(controller: uuidController, label: 'UUID del Dispositivo'),
            const SizedBox(height: 12),
            YtTextField(controller: aliasController, label: 'Alias (Ej: Conductor Juan)'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
          AppButton(
            label: 'Guardar',
            onPressed: () {
              if (uuidController.text.isNotEmpty && aliasController.text.isNotEmpty) {
                context.read<AdminBloc>().add(RegisterDeviceManual(
                      uuid: uuidController.text.trim(),
                      alias: aliasController.text.trim(),
                    ));
                Navigator.pop(dialogContext);
              }
            },
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    final userController = TextEditingController();
    final passController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.backgroundColor,
        title: const Text('Crear Usuario Admin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            YtTextField(controller: userController, label: 'Nombre de Usuario'),
            const SizedBox(height: 12),
            YtTextField(controller: passController, label: 'PIN / Contraseña', isPassword: true),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
          AppButton(
            label: 'Crear',
            onPressed: () {
              if (userController.text.isNotEmpty && passController.text.isNotEmpty) {
                context.read<AdminBloc>().add(CreateUserRequested(
                      username: userController.text.trim(),
                      pin: passController.text.trim(),
                      role: 'ADMIN',
                    ));
                Navigator.pop(dialogContext);
              }
            },
          ),
        ],
      ),
    );
  }

  void _showAddAppUserDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.backgroundColor,
        title: const Text('Crear Usuario App'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            YtTextField(controller: nameController, label: 'Nombre Completo'),
            const SizedBox(height: 12),
            YtTextField(controller: emailController, label: 'Correo Electrónico'),
            const SizedBox(height: 12),
            YtTextField(controller: phoneController, label: 'Teléfono'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
          AppButton(
            label: 'Crear',
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                final emailVal = emailController.text.trim().isNotEmpty
                    ? emailController.text.trim()
                    : '${nameController.text.trim().toLowerCase().replaceAll(' ', '')}@sonopay.com';
                context.read<AdminBloc>().add(CreateAppUserRequested(
                      name: nameController.text.trim(),
                      email: emailVal,
                      password: 'password123',
                      phone: phoneController.text.trim().isNotEmpty ? phoneController.text.trim() : null,
                    ));
                Navigator.pop(dialogContext);
              }
            },
          ),
        ],
      ),
    );
  }

  void _showEditAppUserDialog(BuildContext context, UserProfile profile) {
    final nameController = TextEditingController(text: profile.name);
    final emailController = TextEditingController(text: profile.email ?? '');
    final phoneController = TextEditingController(text: profile.phone ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.backgroundColor,
        title: const Text('Editar Perfil App'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            YtTextField(controller: nameController, label: 'Nombre Completo'),
            const SizedBox(height: 12),
            YtTextField(controller: emailController, label: 'Correo Electrónico'),
            const SizedBox(height: 12),
            YtTextField(controller: phoneController, label: 'Teléfono'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
          AppButton(
            label: 'Guardar',
            onPressed: () {
              if (profile.id != null && nameController.text.isNotEmpty) {
                context.read<AdminBloc>().add(UpdateAppUserRequested(
                      id: profile.id!,
                      name: nameController.text.trim(),
                      email: emailController.text.trim().isNotEmpty ? emailController.text.trim() : null,
                      phone: phoneController.text.trim().isNotEmpty ? phoneController.text.trim() : null,
                    ));
                Navigator.pop(dialogContext);
              }
            },
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAppUser(BuildContext context, UserProfile profile) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('¿Eliminar Perfil?'),
        content: Text('¿Seguro que deseas eliminar el usuario "${profile.name}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            onPressed: () {
              final targetId = profile.id ?? profile.email ?? profile.uuid ?? '';
              if (targetId.isNotEmpty) {
                context.read<AdminBloc>().add(DeleteAppUserRequested(targetId));
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
