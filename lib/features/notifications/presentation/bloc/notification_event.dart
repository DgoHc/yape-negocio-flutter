
abstract class NotificationEvent {}

class GetMyNotificationCode extends NotificationEvent {}

class SendLinkRequest extends NotificationEvent {
  final String code;

  SendLinkRequest(this.code);
}

class GetLinkRequests extends NotificationEvent {}

class AcceptLinkRequest extends NotificationEvent {
  final String requestId;

  AcceptLinkRequest(this.requestId);
}

class RejectLinkRequest extends NotificationEvent {
  final String requestId;

  RejectLinkRequest(this.requestId);
}

class GetLinkedUsers extends NotificationEvent {}

class UpdateLink extends NotificationEvent {
  final String linkId;
  final String? alias;
  final String? status;

  UpdateLink({
    required this.linkId,
    this.alias,
    this.status,
  });
}

class DeleteLink extends NotificationEvent {
  final String linkId;

  DeleteLink(this.linkId);
}

class RegisterFcmToken extends NotificationEvent {
  final String token;
  final String? deviceId;
  final String? deviceName;

  RegisterFcmToken({
    required this.token,
    this.deviceId,
    this.deviceName,
  });
}
