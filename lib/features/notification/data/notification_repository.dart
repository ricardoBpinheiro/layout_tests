import 'package:dio/dio.dart';
import 'package:layout_tests/features/notification/models/notification_item.dart';

class NotificationRepository {
  final Dio _dio;

  NotificationRepository({Dio? dio}) : _dio = dio ?? Dio();

  Future<List<NotificationItem>> fetchNotifications() async {
    try {
      // final response = await _dio.get('https://sua-api.com/notifications');

      // final List<dynamic> data = response.data['notifications'] ?? [];
      // return data.map((json) => NotificationItem.fromJson(json)).toList();

      await Future.delayed(Duration(seconds: 1));

      List<NotificationItem> notifications = [
        NotificationItem(
          id: '1',
          title: 'Novo pedido recebido',
          message:
              'Você recebeu um novo pedido #12345. Clique para visualizar os detalhes.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          type: NotificationType.success,
        ),
        NotificationItem(
          id: '2',
          title: 'Sistema será atualizado',
          message:
              'Manutenção programada para hoje às 23:00. O sistema ficará indisponível por 30 minutos.',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          type: NotificationType.warning,
          isRead: true,
        ),
        NotificationItem(
          id: '3',
          title: 'Erro no processamento',
          message:
              'Ocorreu um erro ao processar o pagamento #98765. Verifique os logs do sistema.',
          timestamp: DateTime.now().subtract(const Duration(hours: 4)),
          type: NotificationType.error,
        ),
        NotificationItem(
          id: '4',
          title: 'Backup concluído',
          message:
              'O backup automático foi concluído com sucesso. Todos os dados estão seguros.',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          type: NotificationType.info,
          isRead: true,
        ),
      ];

      return notifications;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Erro ao buscar notificações',
      );
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await Future.delayed(Duration(seconds: 1));

      // await _dio.patch(
      //   'https://sua-api.com/notifications/$notificationId/read',
      // );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Erro ao marcar como lida',
      );
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await Future.delayed(Duration(seconds: 1));
      // await _dio.patch('https://sua-api.com/notifications/read-all');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Erro ao marcar todas como lidas',
      );
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await Future.delayed(Duration(seconds: 1));
      // await _dio.delete('https://sua-api.com/notifications/$notificationId');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Erro ao excluir notificação',
      );
    }
  }
}
