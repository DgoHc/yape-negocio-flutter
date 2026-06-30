
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/notification_repository.dart';
import 'notification_event.dart';
import 'notification_state.dart';

@injectable
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository _repository;

  NotificationBloc(this._repository) : super(NotificationState()) {
    on<GetMyNotificationCode>(_onGetMyNotificationCode);
    on<SendLinkRequest>(_onSendLinkRequest);
    on<GetLinkRequests>(_onGetLinkRequests);
    on<AcceptLinkRequest>(_onAcceptLinkRequest);
    on<RejectLinkRequest>(_onRejectLinkRequest);
    on<GetLinkedUsers>(_onGetLinkedUsers);
    on<UpdateLink>(_onUpdateLink);
    on<DeleteLink>(_onDeleteLink);
    on<RegisterFcmToken>(_onRegisterFcmToken);
  }

  Future<void> _onGetMyNotificationCode(
    GetMyNotificationCode event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final result = await _repository.getMyNotificationCode();
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (code) => emit(state.copyWith(isLoading: false, notificationCode: code)),
    );
  }

  Future<void> _onSendLinkRequest(
    SendLinkRequest event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final result = await _repository.sendLinkRequest(event.code);
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (_) => emit(state.copyWith(isLoading: false)),
    );
  }

  Future<void> _onGetLinkRequests(
    GetLinkRequests event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final result = await _repository.getLinkRequests();
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (requests) => emit(state.copyWith(isLoading: false, linkRequests: requests)),
    );
  }

  Future<void> _onAcceptLinkRequest(
    AcceptLinkRequest event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final result = await _repository.acceptLinkRequest(event.requestId);
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (_) => emit(state.copyWith(isLoading: false)),
    );
    // Refresh the link requests and linked users
    add(GetLinkRequests());
    add(GetLinkedUsers());
  }

  Future<void> _onRejectLinkRequest(
    RejectLinkRequest event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final result = await _repository.rejectLinkRequest(event.requestId);
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (_) => emit(state.copyWith(isLoading: false)),
    );
    add(GetLinkRequests());
  }

  Future<void> _onGetLinkedUsers(
    GetLinkedUsers event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final result = await _repository.getLinkedUsers();
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (links) => emit(state.copyWith(isLoading: false, linkedUsers: links)),
    );
  }

  Future<void> _onUpdateLink(
    UpdateLink event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final result = await _repository.updateLink(event.linkId, event.alias, event.status);
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (_) => emit(state.copyWith(isLoading: false)),
    );
    add(GetLinkedUsers());
  }

  Future<void> _onDeleteLink(
    DeleteLink event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final result = await _repository.deleteLink(event.linkId);
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (_) => emit(state.copyWith(isLoading: false)),
    );
    add(GetLinkedUsers());
  }

  Future<void> _onRegisterFcmToken(
    RegisterFcmToken event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final result = await _repository.registerFcmToken(event.token, event.deviceId, event.deviceName);
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (_) => emit(state.copyWith(isLoading: false)),
    );
  }
}
