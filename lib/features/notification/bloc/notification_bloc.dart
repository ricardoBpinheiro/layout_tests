import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:layout_tests/features/notification/data/notification_repository.dart';
import 'package:layout_tests/features/notification/models/notification_item.dart';
import 'package:meta/meta.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository _repository;

  NotificationBloc({required NotificationRepository repository})
    : _repository = repository,
      super(NotificationState()) {
    on<NotificationFetchRequested>(_onFetchRequested);
    on<NotificationMarkAsRead>(_onMarkAsRead);
    on<NotificationMarkAllAsRead>(_onMarkAllAsRead);
    on<NotificationDeleted>(_onDeleted);
    on<NotificationTapped>(_onTapped);
  }

  Future<void> _onFetchRequested(
    NotificationFetchRequested event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(status: NotificationStatus.loading));

    try {
      final notifications = await _repository.fetchNotifications();
      final unreadCount = notifications.where((n) => !n.isRead).length;

      emit(
        state.copyWith(
          status: NotificationStatus.success,
          notifications: notifications,
          unreadCount: unreadCount,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: NotificationStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onMarkAsRead(
    NotificationMarkAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _repository.markAsRead(event.notificationId);

      final updatedNotifications = state.notifications.map((n) {
        if (n.id == event.notificationId) {
          return n.copyWith(isRead: true);
        }
        return n;
      }).toList();

      final unreadCount = updatedNotifications.where((n) => !n.isRead).length;

      emit(
        state.copyWith(
          notifications: updatedNotifications,
          unreadCount: unreadCount,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: NotificationStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onMarkAllAsRead(
    NotificationMarkAllAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _repository.markAllAsRead();

      final updatedNotifications = state.notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();

      emit(state.copyWith(notifications: updatedNotifications, unreadCount: 0));
    } catch (e) {
      emit(
        state.copyWith(
          status: NotificationStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDeleted(
    NotificationDeleted event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _repository.deleteNotification(event.notificationId);

      final updatedNotifications = state.notifications
          .where((n) => n.id != event.notificationId)
          .toList();

      final unreadCount = updatedNotifications.where((n) => !n.isRead).length;

      emit(
        state.copyWith(
          notifications: updatedNotifications,
          unreadCount: unreadCount,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: NotificationStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onTapped(NotificationTapped event, Emitter<NotificationState> emit) {
    // Lógica adicional quando uma notificação é clicada
    // Ex: navegar para uma tela específica
  }
}
