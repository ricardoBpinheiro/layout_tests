part of 'action_bloc.dart';

sealed class ActionState {
  const ActionState();
}

class ActionLoading extends ActionState {}

class ActionLoaded extends ActionState {
  final List<ActionItem> actions;
  final ActionItem? selected;
  final List<ActionMessage> messages;
  const ActionLoaded({
    required this.actions,
    this.selected,
    this.messages = const [],
  });

  ActionLoaded copyWith({
    List<ActionItem>? actions,
    ActionItem? selected,
    bool clearSelected = false,
    List<ActionMessage>? messages,
  }) {
    return ActionLoaded(
      actions: actions ?? this.actions,
      selected: clearSelected ? null : (selected ?? this.selected),
      messages: messages ?? this.messages,
    );
  }
}

class ActionError extends ActionState {
  final String message;
  const ActionError(this.message);
}
