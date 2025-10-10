// presentation/action_form_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/action_bloc.dart';
import '../models/action_item.dart';

class ActionFormScreen extends StatefulWidget {
  final ActionItem? initial;
  const ActionFormScreen({super.key, this.initial});

  @override
  State<ActionFormScreen> createState() => _ActionFormScreenState();
}

class _ActionFormScreenState extends State<ActionFormScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  String _status = 'To Do';
  String _priority = 'Média';
  DateTime? _due;
  String _responsible = 'Richard Pine';

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    _title = TextEditingController(text: i?.title ?? '');
    _description = TextEditingController(text: i?.description ?? '');
    _status = i?.status ?? 'To Do';
    _priority = i?.priority ?? 'Média';
    _due = i?.dueDate;
    _responsible = i?.responsible ?? 'Richard Pine';
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Editar Ação' : 'Nova Ação')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: Column(
            children: [
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Informe o título' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _description,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _status,
                items: const [
                  DropdownMenuItem(value: 'To Do', child: Text('To Do')),
                  DropdownMenuItem(value: 'Doing', child: Text('Doing')),
                  DropdownMenuItem(value: 'Done', child: Text('Done')),
                ],
                onChanged: (v) => setState(() => _status = v ?? _status),
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _priority,
                items: const [
                  DropdownMenuItem(value: 'Baixa', child: Text('Baixa')),
                  DropdownMenuItem(value: 'Média', child: Text('Média')),
                  DropdownMenuItem(value: 'Alta', child: Text('Alta')),
                ],
                onChanged: (v) => setState(() => _priority = v ?? _priority),
                decoration: const InputDecoration(
                  labelText: 'Prioridade',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              _DatePickerField(
                label: 'Prazo',
                value: _due,
                onChanged: (d) => setState(() => _due = d),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _responsible,
                decoration: const InputDecoration(
                  labelText: 'Responsável',
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => _responsible = v,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (!_form.currentState!.validate()) return;
                    final bloc = context.read<ActionBloc>();
                    final now = DateTime.now();
                    final item =
                        (widget.initial ??
                                ActionItem(
                                  id: DateTime.now().millisecondsSinceEpoch
                                      .toString(),
                                  code: 'AC-${now.millisecond % 1000}',
                                  title: '',
                                  description: '',
                                  status: 'To Do',
                                  priority: 'Média',
                                  dueDate: null,
                                  responsible: _responsible,
                                  updatedAt: now,
                                ))
                            .copyWith(
                              title: _title.text,
                              description: _description.text,
                              status: _status,
                              priority: _priority,
                              dueDate: _due,
                              responsible: _responsible,
                              updatedAt: now,
                            );

                    if (widget.initial == null) {
                      bloc.add(CreateAction(item));
                    } else {
                      bloc.add(UpdateAction(item));
                    }
                    Navigator.pop(context);
                  },
                  child: Text(isEdit ? 'Salvar' : 'Criar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  const _DatePickerField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? now,
          firstDate: now.subtract(const Duration(days: 365)),
          lastDate: now.add(const Duration(days: 365 * 5)),
        );
        onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, size: 18),
            const SizedBox(width: 8),
            Text(
              value == null
                  ? 'Sem prazo'
                  : '${value!.day}/${value!.month}/${value!.year}',
            ),
          ],
        ),
      ),
    );
  }
}
