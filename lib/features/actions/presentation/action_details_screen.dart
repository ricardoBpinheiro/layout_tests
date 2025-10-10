import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/action_bloc.dart';
import '../models/action_item.dart';
import '../models/action_message.dart';

class ActionDetailsScreen extends StatefulWidget {
  final String actionId;
  const ActionDetailsScreen({super.key, required this.actionId});

  @override
  State<ActionDetailsScreen> createState() => _ActionDetailsScreenState();
}

class _ActionDetailsScreenState extends State<ActionDetailsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    // carregar mensagens
    context.read<ActionBloc>().add(LoadMessages(widget.actionId));
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActionBloc, ActionState>(
      builder: (context, state) {
        if (state is ActionLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (state is! ActionLoaded) return const Scaffold(body: SizedBox());
        final action = state.actions.firstWhere(
          (a) => a.id == widget.actionId,
          orElse: () => state.selected!,
        );

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(''),
            actions: [
              IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
            ],
            bottom: TabBar(
              controller: _tab,
              tabs: const [
                Tab(text: 'Detalhes'),
                Tab(text: 'Atividade'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tab,
            children: [
              _DetailsTab(action: action),
              _ActivityTab(actionId: action.id),
            ],
          ),
        );
      },
    );
  }
}

class _DetailsTab extends StatefulWidget {
  final ActionItem action;
  const _DetailsTab({required this.action});

  @override
  State<_DetailsTab> createState() => _DetailsTabState();
}

class _DetailsTabState extends State<_DetailsTab> {
  late TextEditingController _title;
  late TextEditingController _desc;
  late String _priority;
  late String _status;
  DateTime? _due;
  late String _responsible;

  @override
  void initState() {
    super.initState();
    final a = widget.action;
    _title = TextEditingController(text: a.title);
    _desc = TextEditingController(text: a.description);
    _priority = a.priority;
    _status = a.status;
    _due = a.dueDate;
    _responsible = a.responsible;
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.action;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header do card (AÇÃO + code)
            Row(
              children: [
                const Icon(Icons.checklist_outlined, color: Color(0xFF5B6DFF)),
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
                    a.code,
                    style: const TextStyle(
                      color: Color(0xFF374151),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _title,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Título',
              ),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            // Status (To Do, Doing, Done)
            DropdownButtonFormField<String>(
              value: _status,
              decoration: _pillDecoration(label: 'Status'),
              items: const [
                DropdownMenuItem(value: 'To Do', child: Text('To Do')),
                DropdownMenuItem(value: 'Doing', child: Text('Doing')),
                DropdownMenuItem(value: 'Done', child: Text('Done')),
              ],
              onChanged: (v) => setState(() => _status = v ?? _status),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _desc,
              decoration: _inputDecoration('Descrição'),
              minLines: 1,
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            // Prioridade
            DropdownButtonFormField<String>(
              value: _priority,
              decoration: _inputDecoration('Prioridade'),
              items: const [
                DropdownMenuItem(value: 'Baixa', child: Text('Baixa')),
                DropdownMenuItem(value: 'Média', child: Text('Média')),
                DropdownMenuItem(value: 'Alta', child: Text('Alta')),
              ],
              onChanged: (v) => setState(() => _priority = v ?? _priority),
            ),
            const SizedBox(height: 12),
            // Prazo
            InkWell(
              onTap: () async {
                final now = DateTime.now();
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _due ?? now,
                  firstDate: now.subtract(const Duration(days: 365)),
                  lastDate: now.add(const Duration(days: 365 * 5)),
                );
                if (picked != null) setState(() => _due = picked);
              },
              child: InputDecorator(
                decoration: _inputDecoration('Prazo'),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 18),
                    const SizedBox(width: 8),
                    Text(_due == null ? 'Sem prazo' : _formatDateTime(_due!)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Responsáveis (simplificado)
            InputDecorator(
              decoration: _inputDecoration('Responsáveis'),
              child: Row(
                children: [
                  const Icon(Icons.person_outline),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_responsible)),
                  TextButton(onPressed: () {}, child: const Text('Trocar')),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Recurso (anexos) e Rótulos (atalhos)
            InputDecorator(
              decoration: _inputDecoration('Recurso'),
              child: Row(
                children: [
                  const Icon(Icons.inventory_2_outlined),
                  const SizedBox(width: 8),
                  const Text('Adicionar recursos'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            InputDecorator(
              decoration: _inputDecoration('Rótulos'),
              child: Row(
                children: [
                  const Icon(Icons.label_outline),
                  const SizedBox(width: 8),
                  const Text('Adicionar rótulos'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Rodapé
            Text(
              'Criada por ${a.responsible} em ${_formatDateTime(a.updatedAt)}',
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 4),
            const Row(
              children: [
                Icon(Icons.visibility_outlined, size: 16),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Visível para colaboradores (criador e responsável).',
                    style: TextStyle(color: Color(0xFF6B7280)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Ações
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    final updated = a.copyWith(
                      title: _title.text,
                      description: _desc.text,
                      priority: _priority,
                      status: _status,
                      dueDate: _due,
                    );
                    context.read<ActionBloc>().add(UpdateAction(updated));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ação atualizada')),
                    );
                  },
                  child: const Text('Salvar'),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () {
                    context.read<ActionBloc>().add(DeleteAction(a.id));
                    Navigator.pop(context);
                  },
                  child: const Text('Excluir'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }

  InputDecoration _pillDecoration({required String label}) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFFFF7E6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  String _formatDateTime(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')} de ${_monthPt(d.month)} de ${d.year}, ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  String _monthPt(int m) {
    const months = [
      'jan.',
      'fev.',
      'mar.',
      'abr.',
      'mai.',
      'jun.',
      'jul.',
      'ago.',
      'set.',
      'out.',
      'nov.',
      'dez.',
    ];
    return months[m - 1];
  }
}

class _ActivityTab extends StatefulWidget {
  final String actionId;
  const _ActivityTab({required this.actionId});

  @override
  State<_ActivityTab> createState() => _ActivityTabState();
}

class _ActivityTabState extends State<_ActivityTab> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActionBloc, ActionState>(
      builder: (context, state) {
        if (state is! ActionLoaded) return const SizedBox();
        final messages = state.messages;

        return Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: messages.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) => _MessageBubble(messages[i]),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: IconButton(
                        onPressed: () {
                          // anexar imagem/arquivo
                        },
                        icon: const Icon(Icons.add),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Deixe um comentário.',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Material(
                        color: const Color(0xFF5B6DFF),
                        child: InkWell(
                          onTap: () {
                            final text = _controller.text.trim();
                            if (text.isEmpty) return;
                            context.read<ActionBloc>().add(
                              SendMessage(
                                actionId: widget.actionId,
                                author: 'Você',
                                text: text,
                              ),
                            );
                            _controller.clear();
                          },
                          child: const SizedBox(
                            width: 48,
                            height: 48,
                            child: Icon(Icons.send, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ActionMessage message;
  const _MessageBubble(this.message);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.text.isNotEmpty)
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5B6DFF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'titulos',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            if (message.imageUrl != null)
              Align(
                alignment: Alignment.centerRight,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    message.imageUrl!,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              _formatDate(message.createdAt),
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 4),
            Text(message.text),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    return '${d.day} de ${_monthPt(d.month)} de ${d.year}, ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  String _monthPt(int m) {
    const months = [
      'jan.',
      'fev.',
      'mar.',
      'abr.',
      'mai.',
      'jun.',
      'jul.',
      'ago.',
      'set.',
      'out.',
      'nov.',
      'dez.',
    ];
    return months[m - 1];
  }
}
