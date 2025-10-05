import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:layout_tests/core/widgets/user_selection/bloc/user_selection_bloc.dart';
import 'package:layout_tests/core/widgets/user_selection/domain/models/user_dto.dart';

class UserSelectionModal extends StatelessWidget {
  const UserSelectionModal({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserSelectionBloc, UserSelectionState>(
      builder: (context, state) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            width: 400,
            height: 520,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Selecionar Usuários",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  onChanged: (value) =>
                      context.read<UserSelectionBloc>().add(SearchUsers(value)),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Pesquisar...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(child: _buildContent(context, state)),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Fechar'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, UserSelectionState state) {
    if (state is UserSelectionLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is UserSelectionLoaded) {
      return ListView(
        children: state.groupedUsers.entries.map((entry) {
          final group = entry.key;
          final users = entry.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    context.read<UserSelectionBloc>().add(
                      ToggleGroupSelection(group),
                    );
                  },
                  child: Text(
                    group,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              ...users.map((user) {
                final isSelected = state.selectedUsers.contains(user);
                return _userTile(context, user, isSelected);
              }),
              const SizedBox(height: 12),
            ],
          );
        }).toList(),
      );
    } else if (state is UserSelectionError) {
      return Center(child: Text(state.message));
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _userTile(BuildContext context, UserDTO user, bool isSelected) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFF2563EB).withValues(alpha: 0.1),
        child: Text(
          user.name[0].toUpperCase(),
          style: const TextStyle(color: Color(0xFF2563EB)),
        ),
      ),
      title: Text(user.name),
      subtitle: Text(user.email),
      trailing: Checkbox(
        value: isSelected,
        onChanged: (_) {
          context.read<UserSelectionBloc>().add(ToggleUserSelection(user));
        },
      ),
    );
  }
}
