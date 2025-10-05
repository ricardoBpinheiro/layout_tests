part of 'user_selection_bloc.dart';

abstract class UserSelectionEvent {}

class LoadUsers extends UserSelectionEvent {}

class ToggleUserSelection extends UserSelectionEvent {
  final UserDTO user;
  ToggleUserSelection(this.user);
}

class ToggleGroupSelection extends UserSelectionEvent {
  final String groupName;
  ToggleGroupSelection(this.groupName);
}

class SearchUsers extends UserSelectionEvent {
  final String query;
  SearchUsers(this.query);
}
