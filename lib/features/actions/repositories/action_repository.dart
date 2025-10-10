// data/action_repository.dart
import 'package:layout_tests/features/actions/models/action_item.dart';
import 'package:layout_tests/features/actions/models/action_message.dart';

class ActionRepository {
  final _actions = <ActionItem>[
    ActionItem(
      id: '1',
      code: 'AC-1',
      title: 'teste titulo',
      description: 'teste descrição',
      status: 'To Do',
      priority: 'Média',
      dueDate: DateTime.now().add(const Duration(days: 7)),
      responsible: 'Richard Pine',
      updatedAt: DateTime.now().subtract(const Duration(minutes: 1)),
    ),
    ActionItem(
      id: '2',
      code: 'AC-2',
      title: 'ação 2',
      description: '',
      status: 'To Do',
      priority: 'Baixa',
      dueDate: DateTime.now().add(const Duration(days: 7)),
      responsible: 'Richard Pine',
      updatedAt: DateTime.now().subtract(const Duration(seconds: 31)),
    ),
  ];

  final _messages = <String, List<ActionMessage>>{
    '1': [
      ActionMessage(
        id: 'm1',
        actionId: '1',
        author: 'Você',
        text: 'Você criou a ação.',
        createdAt: DateTime.now().subtract(const Duration(minutes: 1)),
      ),
      ActionMessage(
        id: 'm2',
        actionId: '1',
        author: 'Você',
        text: 'titulos',
        createdAt: DateTime.now().subtract(const Duration(minutes: 1)),
      ),
    ],
    '2': [],
  };

  Future<List<ActionItem>> fetchActions({String search = ''}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (search.isEmpty) return List.of(_actions);
    return _actions
        .where(
          (a) =>
              a.title.toLowerCase().contains(search.toLowerCase()) ||
              a.code.toLowerCase().contains(search.toLowerCase()),
        )
        .toList();
  }

  Future<ActionItem> createAction(ActionItem action) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _actions.add(action);
    _messages[action.id] = [
      ActionMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        actionId: action.id,
        author: 'Você',
        text: 'Você criou a ação.',
        createdAt: DateTime.now(),
      ),
    ];
    return action;
  }

  Future<ActionItem> updateAction(ActionItem action) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = _actions.indexWhere((e) => e.id == action.id);
    if (idx != -1) _actions[idx] = action.copyWith(updatedAt: DateTime.now());
    return _actions[idx];
  }

  Future<void> deleteAction(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _actions.removeWhere((e) => e.id == id);
    _messages.remove(id);
  }

  Future<List<ActionMessage>> fetchMessages(String actionId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.of(_messages[actionId] ?? []);
  }

  Future<ActionMessage> sendMessage({
    required String actionId,
    required String author,
    required String text,
    String? imageUrl,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final msg = ActionMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      actionId: actionId,
      author: author,
      text: text,
      imageUrl: imageUrl,
      createdAt: DateTime.now(),
    );
    _messages[actionId] = [...(_messages[actionId] ?? []), msg];
    return msg;
  }
}
