
import '../../domain/entities/notification_link_entities.dart';

class NotificationState {
  final bool isLoading;
  final String? errorMessage;
  final String? notificationCode;
  final Map<String, dynamic>? foundUser;
  final List<LinkRequest>? linkRequests;
  final List<UserLink>? linkedUsers;

  NotificationState({
    this.isLoading = false,
    this.errorMessage,
    this.notificationCode,
    this.foundUser,
    this.linkRequests,
    this.linkedUsers,
  });

  NotificationState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? notificationCode,
    Map<String, dynamic>? foundUser,
    List<LinkRequest>? linkRequests,
    List<UserLink>? linkedUsers,
  }) {
    return NotificationState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      notificationCode: notificationCode ?? this.notificationCode,
      foundUser: foundUser ?? this.foundUser,
      linkRequests: linkRequests ?? this.linkRequests,
      linkedUsers: linkedUsers ?? this.linkedUsers,
    );
  }
}
