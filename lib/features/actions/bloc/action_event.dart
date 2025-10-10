part of 'action_bloc.dart';

sealed class ActionEvent {
  const ActionEvent();
}

class LoadActions extends ActionEvent {
  final String search;
  const LoadActions({this.search = ''});
}

class CreateAction extends ActionEvent {
  final ActionItem action;
  const CreateAction(this.action);
}

class UpdateAction extends ActionEvent {
  final ActionItem action;
  const UpdateAction(this.action);
}

class DeleteAction extends ActionEvent {
  final String id;
  const DeleteAction(this.id);
}

class SelectAction extends ActionEvent {
  final ActionItem action;
  const SelectAction(this.action);
}

class LoadMessages extends ActionEvent {
  final String actionId;
  const LoadMessages(this.actionId);
}

class SendMessage extends ActionEvent {
  final String actionId;
  final String author;
  final String text;
  final String? imageUrl;
  const SendMessage({
    required this.actionId,
    required this.author,
    required this.text,
    this.imageUrl,
  });
}
