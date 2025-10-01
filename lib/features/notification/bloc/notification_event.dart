part of 'notification_bloc.dart';

@immutable
sealed class NotificationEvent {}

class NotificationFetchRequested extends NotificationEvent {}

class NotificationMarkAsRead extends NotificationEvent {
  final String notificationId;
  NotificationMarkAsRead(this.notificationId);
}

class NotificationMarkAllAsRead extends NotificationEvent {}

class NotificationDeleted extends NotificationEvent {
  final String notificationId;
  NotificationDeleted(this.notificationId);
}

class NotificationTapped extends NotificationEvent {
  final NotificationItem notification;
  NotificationTapped(this.notification);
}
