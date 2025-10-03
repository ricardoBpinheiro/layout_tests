import 'package:flutter/material.dart';
import 'package:layout_tests/features/template_inspections/models/field_types.dart';
import 'package:layout_tests/features/template_inspections/models/inspection_field.dart';
import 'package:layout_tests/features/template_inspections/models/question_rule.dart';

class FieldDisplayWidget extends StatefulWidget {
  final InspectionField field;
  final int fieldIndex;
  final Function(InspectionField) onFieldUpdated;
  final VoidCallback onFieldDeleted;
  final VoidCallback? onDuplicateField;

  const FieldDisplayWidget({
    super.key,
    required this.field,
    required this.fieldIndex,
    required this.onFieldUpdated,
    required this.onFieldDeleted,
    this.onDuplicateField,
  });

  @override
  State<FieldDisplayWidget> createState() => _FieldDisplayWidgetState();
}

class _FieldDisplayWidgetState extends State<FieldDisplayWidget> {
  late TextEditingController _labelController;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.field.label);
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  void _updateField() {
    final updatedField = widget.field.copyWith(label: _labelController.text);
    widget.onFieldUpdated(updatedField);
  }

  String _getFieldTypeDisplayName(FieldType type) {
    switch (type) {
      case FieldType.text:
        return 'Texto';
      case FieldType.number:
        return 'Número';
      case FieldType.email:
        return 'Email';
      case FieldType.phone:
        return 'Telefone';
      case FieldType.select:
        return 'Múltipla escolha';
      case FieldType.multiSelect:
        return 'Seleção múltipla';
      case FieldType.checkbox:
        return 'Sim/Não';
      case FieldType.photo:
        return 'Arquivo';
      case FieldType.signature:
        return 'Assinatura';
      case FieldType.date:
        return 'Data';
      case FieldType.time:
        return 'Hora';
      case FieldType.rating:
        return 'Avaliação';
      case FieldType.predefinedSet:
        return 'Pré-definido';
    }
  }

  IconData _getFieldTypeIcon(FieldType type) {
    switch (type) {
      case FieldType.text:
        return Icons.short_text;
      case FieldType.number:
        return Icons.numbers;
      case FieldType.email:
        return Icons.email;
      case FieldType.phone:
        return Icons.phone;
      case FieldType.select:
        return Icons.radio_button_checked;
      case FieldType.multiSelect:
        return Icons.check_box;
      case FieldType.checkbox:
        return Icons.check_box_outline_blank;
      case FieldType.photo:
        return Icons.file_upload;
      case FieldType.signature:
        return Icons.draw;
      case FieldType.date:
        return Icons.event;
      case FieldType.time:
        return Icons.schedule;
      case FieldType.rating:
        return Icons.star;
      case FieldType.predefinedSet:
        return Icons.list;
    }
  }

  void _showRuleDialog() {
    showDialog(
      context: context,
      builder: (context) => _RuleManagementDialog(
        field: widget.field,
        onFieldUpdated: widget.onFieldUpdated,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableDragStartListener(
      index: widget.fieldIndex,
      child: Container(
        key: ValueKey(widget.field.id),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pergunta + Tipo
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.drag_handle, color: Colors.grey[400]),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _labelController,
                    onChanged: (_) => _updateField(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: const InputDecoration(
                      hintText: "Escreva sua pergunta...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getFieldTypeIcon(widget.field.type),
                        size: 14,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getFieldTypeDisplayName(widget.field.type),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Ações
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.rule, color: Colors.deepPurple),
                  tooltip: 'Adicionar regra',
                  onPressed: _showRuleDialog,
                ),
                IconButton(
                  icon: const Icon(Icons.content_copy),
                  tooltip: 'Duplicar',
                  onPressed: widget.onDuplicateField,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Excluir',
                  onPressed: widget.onFieldDeleted,
                ),
                const Spacer(),
                const Text("Obrigatória"),
                Switch(
                  value: widget.field.required,
                  onChanged: (v) {
                    widget.onFieldUpdated(widget.field.copyWith(required: v));
                  },
                ),
              ],
            ),

            // Opções do campo (se for múltipla seleção)
            if ((widget.field.type == FieldType.select ||
                    widget.field.type == FieldType.multiSelect) &&
                widget.field.options != null &&
                widget.field.options!.isNotEmpty) ...[
              const Divider(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        widget.field.type == FieldType.select
                            ? Icons.radio_button_checked
                            : Icons.check_box,
                        size: 16,
                        color: Colors.green.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Opções (${widget.field.options!.length})',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: widget.field.options!.map((option) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: option.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: option.color.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: option.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              option.label,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (option.score != 0) ...[
                              const SizedBox(width: 4),
                              Text(
                                '(${option.score}pts)',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ],

            // Regras criadas (se houver)
            if (widget.field.rules != null &&
                widget.field.rules!.isNotEmpty) ...[
              const Divider(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.rule,
                        size: 16,
                        color: Colors.deepPurple,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Regras (${widget.field.rules!.length})',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _showRuleDialog,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          minimumSize: Size.zero,
                        ),
                        child: const Text(
                          'Gerenciar',
                          style: TextStyle(fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...widget.field.rules!.take(2).map((r) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.purple.shade200),
                      ),
                      child: Text(
                        "Se resposta ${r.condition} '${r.value}' então ${r.action}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    );
                  }),
                  if (widget.field.rules!.length > 2)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '+ ${widget.field.rules!.length - 2} regra(s) adicional(is)',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RuleManagementDialog extends StatefulWidget {
  final InspectionField field;
  final Function(InspectionField) onFieldUpdated;

  const _RuleManagementDialog({
    required this.field,
    required this.onFieldUpdated,
  });

  @override
  State<_RuleManagementDialog> createState() => _RuleManagementDialogState();
}

class _RuleManagementDialogState extends State<_RuleManagementDialog> {
  late List<QuestionRule> _rules;
  bool _isCreatingNew = false;
  QuestionRule? _editingRule;

  @override
  void initState() {
    super.initState();
    _rules = List.from(widget.field.rules ?? []);
  }

  void _addNewRule() {
    setState(() {
      _isCreatingNew = true;
      _editingRule = null;
    });
  }

  void _editRule(QuestionRule rule) {
    setState(() {
      _editingRule = rule;
      _isCreatingNew = false;
    });
  }

  void _deleteRule(QuestionRule rule) {
    setState(() {
      _rules.removeWhere((r) => r.id == rule.id);
    });
  }

  void _saveRule(QuestionRule rule) {
    setState(() {
      if (_editingRule != null) {
        // Editando regra existente
        final index = _rules.indexWhere((r) => r.id == _editingRule!.id);
        if (index != -1) {
          _rules[index] = rule;
        }
      } else {
        // Criando nova regra
        _rules.add(rule);
      }
      _isCreatingNew = false;
      _editingRule = null;
    });
  }

  void _cancelEdit() {
    setState(() {
      _isCreatingNew = false;
      _editingRule = null;
    });
  }

  void _saveAndClose() {
    final updatedField = widget.field.copyWith(rules: _rules);
    widget.onFieldUpdated(updatedField);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        height: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.rule, color: Colors.deepPurple),
                const SizedBox(width: 8),
                const Text(
                  'Gerenciar Regras',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),

            // Lista de regras existentes
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_rules.isEmpty && !_isCreatingNew && _editingRule == null)
                    const Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.rule, size: 48, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'Nenhuma regra criada',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView(
                        children: [
                          ..._rules.map((rule) => _buildRuleCard(rule)),
                          if (_isCreatingNew || _editingRule != null)
                            _buildRuleForm(),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Footer
            const Divider(),
            Row(
              children: [
                if (!_isCreatingNew && _editingRule == null)
                  ElevatedButton.icon(
                    onPressed: _addNewRule,
                    icon: const Icon(Icons.add),
                    label: const Text('Nova Regra'),
                  ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _saveAndClose,
                  child: const Text('Salvar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleCard(QuestionRule rule) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Se resposta ${rule.condition} '${rule.value}'",
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Então ${rule.action}",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _editRule(rule),
              icon: const Icon(Icons.edit, size: 18),
              tooltip: 'Editar',
            ),
            IconButton(
              onPressed: () => _deleteRule(rule),
              icon: const Icon(Icons.delete, size: 18, color: Colors.red),
              tooltip: 'Excluir',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleForm() {
    final rule = _editingRule;
    String condition = rule?.condition ?? "é";
    String value = rule?.value ?? "";
    String action = rule?.action ?? "Liberar pergunta";

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _editingRule != null ? 'Editando Regra' : 'Nova Regra',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: condition,
                    decoration: const InputDecoration(
                      labelText: "Condição",
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: "é", child: Text("É")),
                      DropdownMenuItem(value: "não é", child: Text("Não é")),
                      DropdownMenuItem(value: "contém", child: Text("Contém")),
                      DropdownMenuItem(
                        value: "não contém",
                        child: Text("Não contém"),
                      ),
                    ],
                    onChanged: (v) => condition = v!,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: value,
                    decoration: const InputDecoration(
                      labelText: "Valor",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => value = v,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: action,
              decoration: const InputDecoration(
                labelText: "Ação",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: "Liberar pergunta",
                  child: Text("Liberar pergunta"),
                ),
                DropdownMenuItem(
                  value: "Exigir ação",
                  child: Text("Exigir ação"),
                ),
                DropdownMenuItem(
                  value: "Exigir evidência",
                  child: Text("Exigir evidência"),
                ),
                DropdownMenuItem(
                  value: "Enviar email",
                  child: Text("Enviar e-mail"),
                ),
              ],
              onChanged: (v) => action = v!,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Spacer(),
                TextButton(
                  onPressed: _cancelEdit,
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (value.isNotEmpty) {
                      final newRule = QuestionRule(
                        id: rule?.id,
                        condition: condition,
                        value: value,
                        action: action,
                      );
                      _saveRule(newRule);
                    }
                  },
                  child: Text(_editingRule != null ? 'Atualizar' : 'Adicionar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
