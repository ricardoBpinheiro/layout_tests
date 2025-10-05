part of 'user_selection_bloc.dart';

abstract class UserSelectionState {}

class UserSelectionInitial extends UserSelectionState {}

class UserSelectionLoading extends UserSelectionState {}

class UserSelectionLoaded extends UserSelectionState {
  final Map<String, List<UserDTO>> groupedUsers;
  final String searchQuery;
  final Set<UserDTO> selectedUsers;

  UserSelectionLoaded({
    required this.groupedUsers,
    this.searchQuery = '',
    this.selectedUsers = const {},
  });

  UserSelectionLoaded copyWith({
    Map<String, List<UserDTO>>? groupedUsers,
    String? searchQuery,
    Set<UserDTO>? selectedUsers,
  }) {
    return UserSelectionLoaded(
      groupedUsers: groupedUsers ?? this.groupedUsers,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedUsers: selectedUsers ?? this.selectedUsers,
    );
  }
}

class UserSelectionError extends UserSelectionState {
  final String message;
  UserSelectionError(this.message);
}
