import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/notification_link_entities.dart';
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
    emit(state.copyWith(isLoading: true, clearError: true));
    final result = await _repository.getMyNotificationCode();
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (code) => emit(state.copyWith(isLoading: false, clearError: true, notificationCode: code)),
    );
  }

  Future<void> _onSendLinkRequest(
    SendLinkRequest event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    final result = await _repository.sendLinkRequest(event.code);
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (_) {
        emit(state.copyWith(isLoading: false, clearError: true));
        add(GetLinkRequests());
      },
    );
  }

  Future<void> _onGetLinkRequests(
    GetLinkRequests event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await _repository.getLinkRequests();
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (requests) => emit(state.copyWith(isLoading: false, clearError: true, linkRequests: requests)),
    );
  }

  Future<void> _onAcceptLinkRequest(
    AcceptLinkRequest event,
    Emitter<NotificationState> emit,
  ) async {
    final reqToAccept = state.linkRequests?.firstWhere(
      (r) => r.id == event.requestId,
      orElse: () => LinkRequest(id: '', senderId: '', receiverId: '', status: '', createdAt: DateTime.now(), updatedAt: DateTime.now()),
    );

    final currentRequests = List<LinkRequest>.from(state.linkRequests ?? [])
      ..removeWhere((r) => r.id == event.requestId);

    final currentLinks = List<UserLink>.from(state.linkedUsers ?? []);
    if (reqToAccept != null && reqToAccept.id.isNotEmpty) {
      currentLinks.insert(0, UserLink(
        id: reqToAccept.id,
        sourceId: reqToAccept.senderId,
        targetId: reqToAccept.receiverId,
        status: 'active',
        linkedAt: DateTime.now(),
        updatedAt: DateTime.now(),
        source: reqToAccept.sender,
        target: reqToAccept.receiver,
      ));
    }

    emit(state.copyWith(
      isLoading: false,
      clearError: true,
      linkRequests: currentRequests,
      linkedUsers: currentLinks,
    ));

    await _repository.acceptLinkRequest(event.requestId);

    final remoteResult = await _repository.getLinkedUsers();
    remoteResult.fold(
      (_) {},
      (remoteLinks) {
        final merged = List<UserLink>.from(remoteLinks);
        for (final local in currentLinks) {
          if (!merged.any((m) => m.id == local.id)) {
            merged.add(local);
          }
        }
        emit(state.copyWith(linkedUsers: merged));
      },
    );
  }

  Future<void> _onRejectLinkRequest(
    RejectLinkRequest event,
    Emitter<NotificationState> emit,
  ) async {
    final currentRequests = List<LinkRequest>.from(state.linkRequests ?? [])
      ..removeWhere((r) => r.id == event.requestId);

    emit(state.copyWith(
      isLoading: false,
      clearError: true,
      linkRequests: currentRequests,
    ));

    await _repository.rejectLinkRequest(event.requestId);
  }

  Future<void> _onGetLinkedUsers(
    GetLinkedUsers event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await _repository.getLinkedUsers();
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (links) => emit(state.copyWith(isLoading: false, clearError: true, linkedUsers: links)),
    );
  }

  Future<void> _onUpdateLink(
    UpdateLink event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    final result = await _repository.updateLink(event.linkId, event.alias, event.status);
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (_) {
        emit(state.copyWith(isLoading: false, clearError: true));
        add(GetLinkedUsers());
      },
    );
  }

  Future<void> _onDeleteLink(
    DeleteLink event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    final result = await _repository.deleteLink(event.linkId);
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (_) {
        emit(state.copyWith(isLoading: false, clearError: true));
        add(GetLinkedUsers());
      },
    );
  }

  Future<void> _onRegisterFcmToken(
    RegisterFcmToken event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    final result = await _repository.registerFcmToken(event.token, event.deviceId, event.deviceName);
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (_) => emit(state.copyWith(isLoading: false, clearError: true)),
    );
  }
}
