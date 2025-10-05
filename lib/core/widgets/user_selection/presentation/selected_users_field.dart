import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:layout_tests/core/widgets/user_selection/bloc/user_selection_bloc.dart';
import 'package:layout_tests/core/widgets/user_selection/domain/models/user_dto.dart';
import 'package:layout_tests/core/widgets/user_selection/presentation/user_selection_modal.dart';

class SelectedUsersField extends StatelessWidget {
  const SelectedUsersField({super.key});

  void _showUserSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BlocProvider.value(
        value: context.read<UserSelectionBloc>(),
        child: const UserSelectionModal(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserSelectionBloc, UserSelectionState>(
      buildWhen: (prev, curr) {
        if (prev is UserSelectionLoaded && curr is UserSelectionLoaded) {
          return prev.selectedUsers.length != curr.selectedUsers.length ||
              !prev.selectedUsers.containsAll(curr.selectedUsers) ||
              !curr.selectedUsers.containsAll(prev.selectedUsers);
        }
        return prev.runtimeType != curr.runtimeType;
      },
      builder: (context, state) {
        final selected = state is UserSelectionLoaded
            ? state.selectedUsers
            : <UserDTO>{};

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Usuários com Permissão de Visualização',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFD1D5DB)),
              ),
              child: InkWell(
                onTap: () => _showUserSelectionDialog(context),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.people, color: Color(0xFF9CA3AF)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: selected.isEmpty
                            ? const Text(
                                'Selecione os usuários...',
                                style: TextStyle(color: Color(0xFF9CA3AF)),
                              )
                            : Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: selected.map((user) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF2563EB,
                                      ).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          user.name,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF2563EB),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        GestureDetector(
                                          onTap: () {
                                            context
                                                .read<UserSelectionBloc>()
                                                .add(ToggleUserSelection(user));
                                          },
                                          child: const Icon(
                                            Icons.close,
                                            size: 12,
                                            color: Color(0xFF2563EB),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                      ),
                      const Icon(
                        Icons.arrow_drop_down,
                        color: Color(0xFF9CA3AF),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
