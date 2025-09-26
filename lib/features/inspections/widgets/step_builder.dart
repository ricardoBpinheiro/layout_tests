import 'package:flutter/material.dart';
import 'package:layout_tests/features/inspections/models/field_option.dart';
import 'package:layout_tests/features/inspections/models/field_types.dart';
import 'package:layout_tests/features/inspections/models/inspection_field.dart';
import 'package:layout_tests/features/inspections/models/inspection_section.dart';
import 'package:layout_tests/features/inspections/models/inspection_step.dart';
import 'package:layout_tests/features/inspections/widgets/field_display_widget.dart';

class StepBuilder extends StatefulWidget {
  final InspectionStep step;
  final int stepIndex;
  final Function(InspectionStep) onStepUpdated;
  final VoidCallback onStepDeleted;
  final VoidCallback onAddField;
  final Function(int) onRemoveField;

  const StepBuilder({
    super.key,
    required this.step,
    required this.stepIndex,
    required this.onStepUpdated,
    required this.onStepDeleted,
    required this.onAddField,
    required this.onRemoveField,
  });

  @override
  State<StepBuilder> createState() => _StepBuilderState();
}

class _StepBuilderState extends State<StepBuilder> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  bool _isMinimized = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.step.name);
    _descriptionController = TextEditingController(
      text: widget.step.description ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateStep() {
    final updatedStep = widget.step.copyWith(
      name: _titleController.text,
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
    );
    widget.onStepUpdated(updatedStep);
  }

  void _toggleMinimized() {
    setState(() {
      _isMinimized = !_isMinimized;
    });
  }

  void _addFieldToStep(FieldType fieldType) {
    final currentFields = widget.step.fields;
    final newOrder = currentFields.isEmpty
        ? 1
        : currentFields.map((f) => f.order).reduce((a, b) => a > b ? a : b) + 1;

    final newField = InspectionField(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      label: '',
      type: fieldType,
      required: false,
      order: newOrder,
    );

    final updatedStep = widget.step.copyWith(
      fields: [...widget.step.fields, newField],
    );
    widget.onStepUpdated(updatedStep);
  }

  void _updateFieldInStep(int fieldIndex, InspectionField updatedField) {
    final updatedFields = List<InspectionField>.from(widget.step.fields);
    updatedFields[fieldIndex] = updatedField;

    final updatedStep = widget.step.copyWith(fields: updatedFields);
    widget.onStepUpdated(updatedStep);
  }

  void _duplicateFieldInStep(int fieldIndex) {
    final originalField = widget.step.fields[fieldIndex];
    final duplicatedField = originalField.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      label: '${originalField.label} (Cópia)',
    );

    final updatedFields = List<InspectionField>.from(widget.step.fields);
    updatedFields.insert(fieldIndex + 1, duplicatedField);

    final updatedStep = widget.step.copyWith(fields: updatedFields);
    widget.onStepUpdated(updatedStep);
  }

  void _reorderFields(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final updatedFields = List<InspectionField>.from(widget.step.fields);
    final field = updatedFields.removeAt(oldIndex);
    updatedFields.insert(newIndex, field);

    final updatedStep = widget.step.copyWith(fields: updatedFields);
    widget.onStepUpdated(updatedStep);
  }

  void _showAddFieldDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddFieldDialog(
        onFieldTypeSelected: _addFieldToStep,
        onShowMultipleChoiceConfig: _showMultipleChoiceConfigDialog,
      ),
    );
  }

  void _showMultipleChoiceConfigDialog(
    BuildContext context,
    FieldType fieldType,
    Function(FieldType) onFieldTypeSelected,
  ) {
    showDialog(
      context: context,
      builder: (context) => _MultipleChoiceConfigDialog(
        fieldType: fieldType,
        onConfigComplete: (options) {
          // Criar o campo com as opções configuradas
          final currentFields = widget.step.fields;
          final newOrder = currentFields.isEmpty
              ? 1
              : currentFields
                        .map((f) => f.order)
                        .reduce((a, b) => a > b ? a : b) +
                    1;

          final newField = InspectionField(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            label: '',
            type: fieldType,
            required: false,
            order: newOrder,
            options: options,
          );

          final updatedStep = widget.step.copyWith(
            fields: [...widget.step.fields, newField],
          );
          widget.onStepUpdated(updatedStep);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header da etapa
          GestureDetector(
            onTap: _toggleMinimized,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: _isMinimized
                    ? BorderRadius.circular(12)
                    : const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.drag_handle, color: Colors.grey[400]),
                      const SizedBox(width: 8),
                      Icon(Icons.layers, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _isMinimized
                            ? Text(
                                _titleController.text.isEmpty
                                    ? 'Nome da etapa...'
                                    : _titleController.text,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade700,
                                ),
                              )
                            : TextFormField(
                                controller: _titleController,
                                onChanged: (_) => _updateStep(),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade700,
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'Nome da etapa...',
                                  border: InputBorder.none,
                                ),
                              ),
                      ),
                      if (_isMinimized) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${widget.step.fields.length} campo(s)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      IconButton(
                        onPressed: _toggleMinimized,
                        icon: Icon(
                          _isMinimized ? Icons.expand_more : Icons.expand_less,
                          color: Colors.blue.shade700,
                        ),
                        tooltip: _isMinimized
                            ? 'Expandir etapa'
                            : 'Minimizar etapa',
                      ),
                      if (!_isMinimized)
                        IconButton(
                          onPressed: widget.onStepDeleted,
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: 'Excluir etapa',
                        ),
                    ],
                  ),
                  if (!_isMinimized) ...[
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      onChanged: (_) => _updateStep(),
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      decoration: const InputDecoration(
                        hintText: 'Descrição da etapa (opcional)...',
                        border: InputBorder.none,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Conteúdo da etapa (campos) - só mostra quando não está minimizada
          if (!_isMinimized)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Lista de campos reordenáveis
                  if (widget.step.fields.isNotEmpty) ...[
                    ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.step.fields.length,
                      onReorder: _reorderFields,
                      itemBuilder: (context, fieldIndex) {
                        return FieldDisplayWidget(
                          key: ValueKey(widget.step.fields[fieldIndex].id),
                          field: widget.step.fields[fieldIndex],
                          fieldIndex: fieldIndex,
                          onFieldUpdated: (updatedField) =>
                              _updateFieldInStep(fieldIndex, updatedField),
                          onFieldDeleted: () =>
                              widget.onRemoveField(fieldIndex),
                          onDuplicateField: () =>
                              _duplicateFieldInStep(fieldIndex),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Botão para adicionar campo no final
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _showAddFieldDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('Adicionar Campo'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${widget.step.fields.length} campo(s) adicionado(s)',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _AddFieldDialog extends StatelessWidget {
  final Function(FieldType) onFieldTypeSelected;
  final Function(BuildContext, FieldType, Function(FieldType))
  onShowMultipleChoiceConfig;

  const _AddFieldDialog({
    required this.onFieldTypeSelected,
    required this.onShowMultipleChoiceConfig,
  });

  void _showMultipleChoiceConfigDialog(
    BuildContext context,
    FieldType fieldType,
  ) {
    onShowMultipleChoiceConfig(context, fieldType, onFieldTypeSelected);
  }

  @override
  Widget build(BuildContext context) {
    final fieldTypes = [
      {'type': FieldType.text, 'name': 'Texto', 'icon': Icons.short_text},
      {'type': FieldType.number, 'name': 'Número', 'icon': Icons.numbers},
      {'type': FieldType.email, 'name': 'Email', 'icon': Icons.email},
      {'type': FieldType.phone, 'name': 'Telefone', 'icon': Icons.phone},
      {
        'type': FieldType.select,
        'name': 'Múltipla escolha',
        'icon': Icons.radio_button_checked,
      },
      {
        'type': FieldType.multiSelect,
        'name': 'Seleção múltipla',
        'icon': Icons.check_box,
      },
      {
        'type': FieldType.checkbox,
        'name': 'Sim/Não',
        'icon': Icons.check_box_outline_blank,
      },
      {'type': FieldType.photo, 'name': 'Arquivo', 'icon': Icons.file_upload},
      {'type': FieldType.signature, 'name': 'Assinatura', 'icon': Icons.draw},
      {'type': FieldType.date, 'name': 'Data', 'icon': Icons.event},
      {'type': FieldType.time, 'name': 'Hora', 'icon': Icons.schedule},
      {'type': FieldType.rating, 'name': 'Avaliação', 'icon': Icons.star},
    ];

    return Dialog(
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.add_circle, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Adicionar Campo',
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
            const SizedBox(height: 16),
            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: fieldTypes.length,
                itemBuilder: (context, index) {
                  final fieldType = fieldTypes[index];
                  return InkWell(
                    onTap: () {
                      final selectedType = fieldType['type'] as FieldType;
                      Navigator.pop(context);

                      // Se for campo de seleção múltipla, abrir modal de configuração
                      if (selectedType == FieldType.select ||
                          selectedType == FieldType.multiSelect) {
                        _showMultipleChoiceConfigDialog(context, selectedType);
                      } else {
                        onFieldTypeSelected(selectedType);
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            fieldType['icon'] as IconData,
                            size: 20,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              fieldType['name'] as String,
                              style: const TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MultipleChoiceConfigDialog extends StatefulWidget {
  final FieldType fieldType;
  final Function(List<FieldOption>) onConfigComplete;

  const _MultipleChoiceConfigDialog({
    required this.fieldType,
    required this.onConfigComplete,
  });

  @override
  State<_MultipleChoiceConfigDialog> createState() =>
      _MultipleChoiceConfigDialogState();
}

class _MultipleChoiceConfigDialogState
    extends State<_MultipleChoiceConfigDialog> {
  List<FieldOption> options = [];
  final TextEditingController _optionController = TextEditingController();

  // Opções pré-definidas
  final Map<String, List<Map<String, dynamic>>> predefinedSets = {
    'Sim/Não/N/D': [
      {'label': 'Sim', 'color': Colors.green, 'score': 10},
      {'label': 'Não', 'color': Colors.red, 'score': 0},
      {'label': 'N/D', 'color': Colors.grey, 'score': 5},
    ],
    'Aprovado/Reprovado': [
      {'label': 'Aprovado', 'color': Colors.green, 'score': 10},
      {'label': 'Reprovado', 'color': Colors.red, 'score': 0},
    ],
    'Excelente/Bom/Regular/Ruim': [
      {'label': 'Excelente', 'color': Colors.green, 'score': 10},
      {'label': 'Bom', 'color': Colors.lightGreen, 'score': 7},
      {'label': 'Regular', 'color': Colors.orange, 'score': 5},
      {'label': 'Ruim', 'color': Colors.red, 'score': 2},
    ],
  };

  @override
  void dispose() {
    _optionController.dispose();
    super.dispose();
  }

  void _addPredefinedSet(String setName) {
    final predefinedOptions = predefinedSets[setName]!;
    setState(() {
      options.clear();
      for (var option in predefinedOptions) {
        options.add(
          FieldOption(
            id:
                DateTime.now().millisecondsSinceEpoch.toString() +
                options.length.toString(),
            label: option['label'],
            color: option['color'],
            score: option['score'],
          ),
        );
      }
    });
  }

  void _addCustomOption() {
    if (_optionController.text.trim().isNotEmpty) {
      setState(() {
        options.add(
          FieldOption(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            label: _optionController.text.trim(),
            color: Colors.blue,
            score: 0,
          ),
        );
        _optionController.clear();
      });
    }
  }

  void _removeOption(int index) {
    setState(() {
      options.removeAt(index);
    });
  }

  void _updateOption(int index, FieldOption updatedOption) {
    setState(() {
      options[index] = updatedOption;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  widget.fieldType == FieldType.select
                      ? Icons.radio_button_checked
                      : Icons.check_box,
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
                Text(
                  'Configurar ${widget.fieldType == FieldType.select ? "Múltipla Escolha" : "Seleção Múltipla"}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),

            // Opções pré-definidas
            const Text(
              'Conjuntos Pré-definidos:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: predefinedSets.keys.map((setName) {
                return ElevatedButton(
                  onPressed: () => _addPredefinedSet(setName),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade50,
                    foregroundColor: Colors.blue.shade700,
                  ),
                  child: Text(setName),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Adicionar opção customizada
            const Text(
              'Adicionar Opção Personalizada:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _optionController,
                    decoration: const InputDecoration(
                      hintText: 'Digite uma nova opção...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addCustomOption(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addCustomOption,
                  child: const Text('Adicionar'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Lista de opções configuradas
            if (options.isNotEmpty) ...[
              const Text(
                'Opções Configuradas:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options[index];
                    return _OptionConfigCard(
                      option: option,
                      onUpdate: (updatedOption) =>
                          _updateOption(index, updatedOption),
                      onDelete: () => _removeOption(index),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Botões de ação
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: options.isNotEmpty
                      ? () {
                          widget.onConfigComplete(options);
                          Navigator.pop(context);
                        }
                      : null,
                  child: const Text('Confirmar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionConfigCard extends StatefulWidget {
  final FieldOption option;
  final Function(FieldOption) onUpdate;
  final VoidCallback onDelete;

  const _OptionConfigCard({
    required this.option,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<_OptionConfigCard> createState() => _OptionConfigCardState();
}

class _OptionConfigCardState extends State<_OptionConfigCard> {
  late TextEditingController _labelController;
  late TextEditingController _scoreController;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.option.label);
    _scoreController = TextEditingController(
      text: widget.option.score.toString(),
    );
  }

  @override
  void dispose() {
    _labelController.dispose();
    _scoreController.dispose();
    super.dispose();
  }

  void _updateOption() {
    final updatedOption = widget.option.copyWith(
      label: _labelController.text,
      score: int.tryParse(_scoreController.text) ?? 0,
    );
    widget.onUpdate(updatedOption);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Cor da opção
          GestureDetector(
            onTap: () {
              // Aqui você pode implementar um color picker
              _showColorPicker();
            },
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: widget.option.color,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey.shade400),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Label da opção
          Expanded(
            flex: 2,
            child: TextField(
              controller: _labelController,
              onChanged: (_) => _updateOption(),
              decoration: const InputDecoration(
                hintText: 'Nome da opção',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Pontuação
          Expanded(
            child: TextField(
              controller: _scoreController,
              onChanged: (_) => _updateOption(),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Pontos',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Botão de excluir
          IconButton(
            onPressed: widget.onDelete,
            icon: const Icon(Icons.delete, color: Colors.red),
            iconSize: 20,
          ),
        ],
      ),
    );
  }

  void _showColorPicker() {
    final colors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.grey,
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Escolher Cor'),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: colors.map((color) {
            return GestureDetector(
              onTap: () {
                final updatedOption = widget.option.copyWith(color: color);
                widget.onUpdate(updatedOption);
                Navigator.pop(context);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: widget.option.color == color
                        ? Colors.black
                        : Colors.grey.shade400,
                    width: widget.option.color == color ? 2 : 1,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
