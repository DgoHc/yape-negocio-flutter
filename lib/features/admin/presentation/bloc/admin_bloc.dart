import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/entities/user_profile.dart';
import '../../domain/usecases/get_devices_use_case.dart';
import '../../domain/usecases/get_users_use_case.dart';
import '../../domain/usecases/get_user_profiles_use_case.dart';
import '../../domain/usecases/update_user_profile_subscription_use_case.dart';
import '../../domain/usecases/register_device_manual_use_case.dart';
import '../../domain/usecases/update_device_status_use_case.dart';
import '../../domain/usecases/delete_device_use_case.dart';
import '../../domain/usecases/create_user_use_case.dart';
import '../../domain/usecases/update_user_use_case.dart';
import '../../domain/usecases/delete_user_use_case.dart';
import '../../domain/usecases/export_admin_data_use_case.dart';

// Events
abstract class AdminEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadDevices extends AdminEvent {}

class LoadUsers extends AdminEvent {}

class LoadUserProfiles extends AdminEvent {}

class UpdateUserProfileSubscription extends AdminEvent {
  final String id;
  final bool isSubscribed;
  UpdateUserProfileSubscription({required this.id, required this.isSubscribed});

  @override
  List<Object?> get props => [id, isSubscribed];
}

class RegisterDeviceManual extends AdminEvent {
  final String uuid;
  final String alias;
  final String? phoneNumber;
  RegisterDeviceManual({required this.uuid, required this.alias, this.phoneNumber});

  @override
  List<Object?> get props => [uuid, alias, phoneNumber];
}

class UpdateDeviceStatus extends AdminEvent {
  final String id;
  final bool? isApproved;
  final String? status;
  UpdateDeviceStatus({required this.id, this.isApproved, this.status});

  @override
  List<Object?> get props => [id, isApproved, status];
}

class DeleteDeviceRequested extends AdminEvent {
  final String id;
  DeleteDeviceRequested(this.id);

  @override
  List<Object?> get props => [id];
}

class CreateUserRequested extends AdminEvent {
  final String username;
  final String pin;
  final String role;
  CreateUserRequested({required this.username, required this.pin, required this.role});

  @override
  List<Object?> get props => [username, pin, role];
}

class UpdateUserStatus extends AdminEvent {
  final String id;
  final String? role;
  final String? status;
  UpdateUserStatus({required this.id, this.role, this.status});

  @override
  List<Object?> get props => [id, role, status];
}

class DeleteUserRequested extends AdminEvent {
  final String id;
  DeleteUserRequested(this.id);

  @override
  List<Object?> get props => [id];
}

class ExportAdminDataRequested extends AdminEvent {}

// States
enum AdminStatus { initial, loading, success, failure, exporting }

class AdminState extends Equatable {
  final AdminStatus status;
  final List<Map<String, dynamic>> devices;
  final List<Map<String, dynamic>> users;
  final List<UserProfile> userProfiles;
  final String? error;
  final String? message;

  const AdminState({
    this.status = AdminStatus.initial,
    this.devices = const [],
    this.users = const [],
    this.userProfiles = const [],
    this.error,
    this.message,
  });

  AdminState copyWith({
    AdminStatus? status,
    List<Map<String, dynamic>>? devices,
    List<Map<String, dynamic>>? users,
    List<UserProfile>? userProfiles,
    String? error,
    String? message,
  }) {
    return AdminState(
      status: status ?? this.status,
      devices: devices ?? this.devices,
      users: users ?? this.users,
      userProfiles: userProfiles ?? this.userProfiles,
      error: error ?? this.error,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, devices, users, userProfiles, error, message];
}

@injectable
class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final GetDevicesUseCase _getDevicesUseCase;
  final GetUsersUseCase _getUsersUseCase;
  final GetUserProfilesUseCase _getUserProfilesUseCase;
  final UpdateUserProfileSubscriptionUseCase _updateUserProfileSubscriptionUseCase;
  final RegisterDeviceManualUseCase _registerDeviceManualUseCase;
  final UpdateDeviceStatusUseCase _updateDeviceStatusUseCase;
  final DeleteDeviceUseCase _deleteDeviceUseCase;
  final CreateUserUseCase _createUserUseCase;
  final UpdateUserUseCase _updateUserUseCase;
  final DeleteUserUseCase _deleteUserUseCase;
  final ExportAdminDataUseCase _exportAdminDataUseCase;

  AdminBloc(
    this._getDevicesUseCase,
    this._getUsersUseCase,
    this._getUserProfilesUseCase,
    this._updateUserProfileSubscriptionUseCase,
    this._registerDeviceManualUseCase,
    this._updateDeviceStatusUseCase,
    this._deleteDeviceUseCase,
    this._createUserUseCase,
    this._updateUserUseCase,
    this._deleteUserUseCase,
    this._exportAdminDataUseCase,
  ) : super(const AdminState()) {
    on<LoadDevices>(_onLoadDevices);
    on<LoadUsers>(_onLoadUsers);
    on<LoadUserProfiles>(_onLoadUserProfiles);
    on<UpdateUserProfileSubscription>(_onUpdateUserProfileSubscription);
    on<RegisterDeviceManual>(_onRegisterDeviceManual);
    on<UpdateDeviceStatus>(_onUpdateDeviceStatus);
    on<DeleteDeviceRequested>(_onDeleteDeviceRequested);
    on<CreateUserRequested>(_onCreateUserRequested);
    on<UpdateUserStatus>(_onUpdateUserStatus);
    on<DeleteUserRequested>(_onDeleteUserRequested);
    on<ExportAdminDataRequested>(_onExportAdminDataRequested);
  }

  Future<void> _onLoadDevices(LoadDevices event, Emitter<AdminState> emit) async {
    emit(state.copyWith(status: AdminStatus.loading));
    final result = await _getDevicesUseCase(const NoParams());
    result.fold(
      (failure) => emit(state.copyWith(status: AdminStatus.failure, error: failure.message)),
      (devices) => emit(state.copyWith(status: AdminStatus.success, devices: devices)),
    );
  }

  Future<void> _onLoadUsers(LoadUsers event, Emitter<AdminState> emit) async {
    emit(state.copyWith(status: AdminStatus.loading));
    final result = await _getUsersUseCase(const NoParams());
    result.fold(
      (failure) => emit(state.copyWith(status: AdminStatus.failure, error: failure.message)),
      (users) => emit(state.copyWith(status: AdminStatus.success, users: users)),
    );
  }

  Future<void> _onLoadUserProfiles(LoadUserProfiles event, Emitter<AdminState> emit) async {
    emit(state.copyWith(status: AdminStatus.loading));
    final result = await _getUserProfilesUseCase(const NoParams());
    result.fold(
      (failure) => emit(state.copyWith(status: AdminStatus.failure, error: failure.message)),
      (profiles) => emit(state.copyWith(status: AdminStatus.success, userProfiles: profiles)),
    );
  }

  Future<void> _onUpdateUserProfileSubscription(
      UpdateUserProfileSubscription event, Emitter<AdminState> emit) async {
    emit(state.copyWith(status: AdminStatus.loading));
    final result = await _updateUserProfileSubscriptionUseCase(
      UpdateUserProfileSubscriptionParams(id: event.id, isSubscribed: event.isSubscribed),
    );
    result.fold(
      (failure) => emit(state.copyWith(status: AdminStatus.failure, error: failure.message)),
      (_) {
        emit(state.copyWith(status: AdminStatus.success, message: 'Suscripción actualizada'));
        add(LoadUserProfiles());
      },
    );
  }

  Future<void> _onRegisterDeviceManual(RegisterDeviceManual event, Emitter<AdminState> emit) async {
    emit(state.copyWith(status: AdminStatus.loading));
    final result = await _registerDeviceManualUseCase(
      RegisterDeviceManualParams(
        uuid: event.uuid,
        alias: event.alias,
        phoneNumber: event.phoneNumber,
      ),
    );
    result.fold(
      (failure) => emit(state.copyWith(status: AdminStatus.failure, error: failure.message)),
      (_) {
        emit(state.copyWith(status: AdminStatus.success, message: 'Dispositivo registrado con éxito'));
        add(LoadDevices());
      },
    );
  }

  Future<void> _onUpdateDeviceStatus(UpdateDeviceStatus event, Emitter<AdminState> emit) async {
    // Optimistic Update
    final updatedDevices = state.devices.map((device) {
      if (device['id'].toString() == event.id) {
        return {
          ...device,
          if (event.isApproved != null) 'isApproved': event.isApproved,
          if (event.status != null) 'status': event.status,
        };
      }
      return device;
    }).toList();
    
    emit(state.copyWith(devices: updatedDevices));

    final result = await _updateDeviceStatusUseCase(
      UpdateDeviceStatusParams(
        id: event.id,
        isApproved: event.isApproved,
        status: event.status,
      ),
    );
    
    result.fold(
      (failure) {
        emit(state.copyWith(status: AdminStatus.failure, error: failure.message));
        add(LoadDevices());
      },
      (_) {
        emit(state.copyWith(status: AdminStatus.success, message: 'Estado actualizado correctamente'));
        add(LoadDevices());
      },
    );
  }

  Future<void> _onDeleteDeviceRequested(DeleteDeviceRequested event, Emitter<AdminState> emit) async {
    final result = await _deleteDeviceUseCase(event.id);
    result.fold(
      (failure) => emit(state.copyWith(status: AdminStatus.failure, error: failure.message)),
      (_) {
        emit(state.copyWith(status: AdminStatus.success, message: 'Dispositivo eliminado'));
        add(LoadDevices());
      },
    );
  }

  Future<void> _onCreateUserRequested(CreateUserRequested event, Emitter<AdminState> emit) async {
    emit(state.copyWith(status: AdminStatus.loading));
    final result = await _createUserUseCase(
      CreateUserParams(username: event.username, pin: event.pin, role: event.role),
    );
    result.fold(
      (failure) => emit(state.copyWith(status: AdminStatus.failure, error: failure.message)),
      (_) {
        emit(state.copyWith(status: AdminStatus.success, message: 'Usuario creado con éxito'));
        add(LoadUsers());
      },
    );
  }

  Future<void> _onUpdateUserStatus(UpdateUserStatus event, Emitter<AdminState> emit) async {
    final result = await _updateUserUseCase(
      UpdateUserParams(id: event.id, role: event.role, status: event.status),
    );
    result.fold(
      (failure) => emit(state.copyWith(status: AdminStatus.failure, error: failure.message)),
      (_) {
        emit(state.copyWith(status: AdminStatus.success, message: 'Usuario actualizado'));
        add(LoadUsers());
      },
    );
  }

  Future<void> _onDeleteUserRequested(DeleteUserRequested event, Emitter<AdminState> emit) async {
    final result = await _deleteUserUseCase(event.id);
    result.fold(
      (failure) => emit(state.copyWith(status: AdminStatus.failure, error: failure.message)),
      (_) {
        emit(state.copyWith(status: AdminStatus.success, message: 'Usuario eliminado'));
        add(LoadUsers());
      },
    );
  }

  Future<void> _onExportAdminDataRequested(
      ExportAdminDataRequested event, Emitter<AdminState> emit) async {
    emit(state.copyWith(status: AdminStatus.exporting));
    final result = await _exportAdminDataUseCase(
      ExportAdminDataParams(
        userProfiles: state.userProfiles,
        devices: state.devices,
      ),
    );
    result.fold(
      (failure) => emit(state.copyWith(status: AdminStatus.failure, error: failure.message)),
      (_) => emit(state.copyWith(status: AdminStatus.success)),
    );
  }
}
