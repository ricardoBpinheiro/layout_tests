import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:layout_tests/features/actions/models/action_item.dart';
import 'package:layout_tests/features/actions/models/action_message.dart';
import 'package:layout_tests/features/actions/repositories/action_repository.dart';

part 'action_event.dart';
part 'action_state.dart';

class ActionBloc extends Bloc<ActionEvent, ActionState> {
  final ActionRepository repository;
  ActionBloc({required this.repository}) : super(ActionLoading()) {
    on<LoadActions>(_onLoadActions);
    on<CreateAction>(_onCreateAction);
    on<UpdateAction>(_onUpdateAction);
    on<DeleteAction>(_onDeleteAction);
    on<SelectAction>(_onSelectAction);
    on<LoadMessages>(_onLoadMessages);
    on<SendMessage>(_onSendMessage);
  }
  Future<void> _onLoadActions(LoadActions e, Emitter<ActionState> emit) async {
    emit(ActionLoading());
    try {
      final list = await repository.fetchActions(search: e.search);
      emit(ActionLoaded(actions: list));
    } catch (err) {
      emit(ActionError('Falha ao carregar ações'));
    }
  }

  Future<void> _onCreateAction(
    CreateAction e,
    Emitter<ActionState> emit,
  ) async {
    if (state is! ActionLoaded) return;
    final s = state as ActionLoaded;
    try {
      final created = await repository.createAction(e.action);
      emit(s.copyWith(actions: [...s.actions, created]));
    } catch (_) {
      emit(ActionError('Falha ao criar ação'));
    }
  }

  Future<void> _onUpdateAction(
    UpdateAction e,
    Emitter<ActionState> emit,
  ) async {
    if (state is! ActionLoaded) return;
    final s = state as ActionLoaded;
    try {
      final updated = await repository.updateAction(e.action);
      final list = s.actions
          .map((a) => a.id == updated.id ? updated : a)
          .toList();
      emit(s.copyWith(actions: list, selected: updated));
    } catch (_) {
      emit(ActionError('Falha ao atualizar ação'));
    }
  }

  Future<void> _onDeleteAction(
    DeleteAction e,
    Emitter<ActionState> emit,
  ) async {
    if (state is! ActionLoaded) return;
    final s = state as ActionLoaded;
    try {
      await repository.deleteAction(e.id);
      emit(
        s.copyWith(
          actions: s.actions.where((a) => a.id != e.id).toList(),
          clearSelected: true,
        ),
      );
    } catch (_) {
      emit(ActionError('Falha ao deletar ação'));
    }
  }

  void _onSelectAction(SelectAction e, Emitter<ActionState> emit) {
    if (state is! ActionLoaded) return;
    final s = state as ActionLoaded;
    emit(s.copyWith(selected: e.action, messages: []));
  }

  Future<void> _onLoadMessages(
    LoadMessages e,
    Emitter<ActionState> emit,
  ) async {
    // if (state is! ActionLoaded) return;
    // final s = state as ActionLoaded;
    final msgs = await repository.fetchMessages(e.actionId);
    final actions = await repository.fetchActions();
    emit(
      ActionLoaded(
        messages: msgs,
        selected: actions.firstWhere((aa) => aa.id == e.actionId),
        actions: actions,
      ),
    );

    // emit(s.copyWith(messages: msgs));
  }

  Future<void> _onSendMessage(SendMessage e, Emitter<ActionState> emit) async {
    if (state is! ActionLoaded) return;
    final s = state as ActionLoaded;
    await repository.sendMessage(
      actionId: e.actionId,
      author: e.author,
      text: e.text,
      imageUrl: e.imageUrl,
    );
    final msgs = await repository.fetchMessages(e.actionId);
    emit(s.copyWith(messages: msgs));
  }
}
