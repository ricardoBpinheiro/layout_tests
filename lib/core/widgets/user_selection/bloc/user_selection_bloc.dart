import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:layout_tests/core/widgets/user_selection/domain/models/user_dto.dart';
import 'package:layout_tests/core/widgets/user_selection/domain/repositories/user_repository.dart';

part 'user_selection_event.dart';
part 'user_selection_state.dart';

class UserSelectionBloc extends Bloc<UserSelectionEvent, UserSelectionState> {
  final UserRepository repository;
  List<UserDTO> _allUsers = [];

  UserSelectionBloc(this.repository) : super(UserSelectionInitial()) {
    on<LoadUsers>(_onLoadUsers);
    on<SearchUsers>(_onSearchUsers);
    on<ToggleUserSelection>(_onToggleUserSelection);
    on<ToggleGroupSelection>(_onToggleGroupSelection);
  }

  Future<void> _onLoadUsers(
    LoadUsers event,
    Emitter<UserSelectionState> emit,
  ) async {
    emit(UserSelectionLoading());
    try {
      _allUsers = await repository.fetchUsers();
      _allUsers.sort((a, b) => a.name.compareTo(b.name));
      final grouped = _groupUsers();
      emit(UserSelectionLoaded(groupedUsers: grouped));
    } catch (e) {
      emit(UserSelectionError(e.toString()));
    }
  }

  void _onSearchUsers(SearchUsers event, Emitter<UserSelectionState> emit) {
    final query = event.query.toLowerCase();
    final filtered = _allUsers
        .where(
          (u) =>
              u.name.toLowerCase().contains(query) ||
              u.email.toLowerCase().contains(query),
        )
        .toList();
    final grouped = _groupUsers(filtered);
    emit(UserSelectionLoaded(groupedUsers: grouped, searchQuery: query));
  }

  void _onToggleUserSelection(
    ToggleUserSelection event,
    Emitter<UserSelectionState> emit,
  ) {
    if (state is UserSelectionLoaded) {
      final currentState = state as UserSelectionLoaded;
      final selected = Set<UserDTO>.from(currentState.selectedUsers);

      if (selected.contains(event.user)) {
        selected.remove(event.user);
      } else {
        selected.add(event.user);
      }

      emit(currentState.copyWith(selectedUsers: selected));
    }
  }

  void _onToggleGroupSelection(
    ToggleGroupSelection event,
    Emitter<UserSelectionState> emit,
  ) {
    if (state is UserSelectionLoaded) {
      final currentState = state as UserSelectionLoaded;
      final selected = Set<UserDTO>.from(currentState.selectedUsers);

      final groupUsers = currentState.groupedUsers[event.groupName] ?? [];

      // Verifica se todos já estão selecionados
      final allSelected = groupUsers.every((u) => selected.contains(u));

      if (allSelected) {
        // Desmarca todos do grupo
        selected.removeAll(groupUsers);
      } else {
        // Seleciona todos do grupo
        selected.addAll(groupUsers);
      }

      emit(currentState.copyWith(selectedUsers: selected));
    }
  }

  Map<String, List<UserDTO>> _groupUsers([List<UserDTO>? users]) {
    final list = users ?? _allUsers;
    final Map<String, List<UserDTO>> grouped = {};
    for (var user in list) {
      grouped.putIfAbsent(user.groupName, () => []).add(user);
    }
    return grouped;
  }
}
