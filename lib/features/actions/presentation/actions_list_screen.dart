import 'package:flutter/material.dart' hide SelectAction;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:layout_tests/features/actions/presentation/action_details_screen.dart';
import 'package:layout_tests/features/actions/presentation/action_form_screen.dart';
import 'package:layout_tests/features/actions/repositories/action_repository.dart';
import '../bloc/action_bloc.dart';
import '../models/action_item.dart';

class ActionsListScreen extends StatelessWidget {
  const ActionsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ActionBloc(repository: ActionRepository())..add(const LoadActions()),
      child: const _ActionsListView(),
    );
  }
}

class _ActionsListView extends StatefulWidget {
  const _ActionsListView();

  @override
  State<_ActionsListView> createState() => _ActionsListViewState();
}

class _ActionsListViewState extends State<_ActionsListView> {
  final _search = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActionBloc, ActionState>(
      builder: (context, state) {
        if (state is ActionLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is ActionLoaded) {
          final actions = state.actions;
          return Scaffold(
            appBar: AppBar(
              title: const Text('Ações'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.calendar_today_outlined),
                  onPressed: () {},
                ),
              ],
            ),
            body: Column(
              children: [
                // filtros rápidos (chips) podem ser adicionados aqui
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: TextField(
                    controller: _search,
                    decoration: InputDecoration(
                      hintText: 'Pesquisar',
                      prefixIcon: const Icon(Icons.search),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    // onChanged: (v) =>
                    //     context.read<ActionBloc>().add(LoadActions(search: v)),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: actions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final a = actions[i];
                      return _ActionCard(
                        action: a,
                        onTap: () async {
                          context.read<ActionBloc>().add(SelectAction(a));
                          await context.push('/actions/${a.id}');
                          // ao voltar, recarrega para refletir mudanças
                          // context.read<ActionBloc>().add(const LoadActions());
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ActionFormScreen()),
                );
              },
              child: const Icon(Icons.add),
            ),
            bottomNavigationBar: _MobileBottomBar(currentIndex: 2), // opcional
          );
        }
        return const Scaffold(body: SizedBox());
      },
    );
  }
}

class _ActionCard extends StatelessWidget {
  final ActionItem action;
  final VoidCallback onTap;
  const _ActionCard({required this.action, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final status = _statusBadge(action.status);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // topo com etiqueta AÇÃO e code
              Row(
                children: [
                  const Icon(
                    Icons.checklist_outlined,
                    color: Color(0xFF5B6DFF),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'AÇÃO',
                    style: TextStyle(
                      color: Color(0xFF5B6DFF),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF1F5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      action.code,
                      style: const TextStyle(
                        color: Color(0xFF374151),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                action.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _priorityLabel(action.priority),
                style: const TextStyle(color: Color(0xFF6B7280)),
              ),
              Text(
                _dueIn(action.dueDate),
                style: const TextStyle(color: Color(0xFF6B7280)),
              ),
              Text(
                'Atribuída a ${action.responsible}',
                style: const TextStyle(color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Atualizado ${_timeAgo(action.updatedAt)}',
                      style: const TextStyle(color: Color(0xFF9CA3AF)),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: status.bg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      status.label,
                      style: TextStyle(
                        color: status.fg,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _priorityLabel(String p) => p;
  String _dueIn(DateTime? date) => date == null
      ? '-'
      : 'Em ${date.difference(DateTime.now()).inDays.abs()} dias';
  String _timeAgo(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'Há ${diff.inSeconds} segundos';
    if (diff.inHours < 1) return 'Há ${diff.inMinutes} minutos';
    if (diff.inDays < 1) return 'Há ${diff.inHours} horas';
    return 'Há ${diff.inDays} dias';
  }

  _StatusColors _statusBadge(String s) {
    final l = s.toLowerCase();
    if (l.contains('done') || l.contains('concl')) {
      return _StatusColors(
        label: 'Concluída',
        bg: const Color(0xFFE9FDF1),
        fg: const Color(0xFF059669),
      );
    } else if (l.contains('doing') || l.contains('andamento')) {
      return _StatusColors(
        label: 'Em andamento',
        bg: const Color(0xFFEFF6FF),
        fg: const Color(0xFF2563EB),
      );
    }
    return _StatusColors(
      label: 'A fazer',
      bg: const Color(0xFFFFF7E6),
      fg: const Color(0xFFB45309),
    );
  }
}

class _StatusColors {
  final String label;
  final Color bg;
  final Color fg;
  _StatusColors({required this.label, required this.bg, required this.fg});
}

class _MobileBottomBar extends StatelessWidget {
  final int currentIndex;
  const _MobileBottomBar({required this.currentIndex});
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (_) {},
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Início',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment_outlined),
          label: 'Inspeções',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.check_box_outlined),
          label: 'Ações',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.school_outlined),
          label: 'Treinamento',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.grid_view_rounded),
          label: 'Mais',
        ),
      ],
    );
  }
}
