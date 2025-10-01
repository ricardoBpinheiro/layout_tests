part of 'notification_bloc.dart';

@immutable
class NotificationState {
  final NotificationStatus status;
  final List<NotificationItem> notifications;
  final String? errorMessage;
  final int unreadCount;

  const NotificationState({
    this.status = NotificationStatus.initial,
    this.notifications = const [],
    this.errorMessage,
    this.unreadCount = 0,
  });

  NotificationState copyWith({
    NotificationStatus? status,
    List<NotificationItem>? notifications,
    String? errorMessage,
    int? unreadCount,
  }) {
    return NotificationState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      errorMessage: errorMessage,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

enum NotificationStatus { initial, loading, success, failure }
