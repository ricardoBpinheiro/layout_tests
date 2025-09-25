import 'package:flutter/material.dart';
import 'package:layout_tests/features/inspections/models/inspection_field.dart';
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
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.step.name);
    _descriptionController = TextEditingController(
      text: widget.step.description,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateStep() {
    final updatedStep = widget.step.copyWith(
      name: _nameController.text,
      description: _descriptionController.text,
    );
    widget.onStepUpdated(updatedStep);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header da Etapa - Similar ao Google Forms
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: const Color(0xFF4285f4), width: 6),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Etapa ${widget.stepIndex + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _nameController,
                            onChanged: (_) => _updateStep(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF202124),
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Título da etapa',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _descriptionController,
                            onChanged: (_) => _updateStep(),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Descrição da etapa (opcional)',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Menu de ações
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'duplicate',
                          child: Row(
                            children: [
                              Icon(Icons.content_copy, size: 16),
                              SizedBox(width: 8),
                              Text('Duplicar etapa'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 16, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Excluir etapa',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'delete') {
                          widget.onStepDeleted();
                        }
                        // TODO: Implementar duplicação
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Lista de Campos da Etapa
          if (widget.step.fields.isNotEmpty) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: List.generate(widget.step.fields.length, (
                  fieldIndex,
                ) {
                  final field = widget.step.fields[fieldIndex];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: FieldDisplayWidget(
                      field: field,
                      fieldIndex: fieldIndex,
                      onFieldUpdated: (updatedField) {
                        final fields = List<InspectionField>.from(
                          widget.step.fields,
                        );
                        fields[fieldIndex] = updatedField;
                        widget.onStepUpdated(
                          widget.step.copyWith(fields: fields),
                        );
                      },
                      onFieldDeleted: () => widget.onRemoveField(fieldIndex),
                    ),
                  );
                }),
              ),
            ),
          ],

          // Botão para adicionar campo - Similar ao Google Forms
          Container(
            padding: const EdgeInsets.all(24),
            child: OutlinedButton.icon(
              onPressed: widget.onAddField,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Adicionar pergunta'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                side: BorderSide(color: Colors.grey[300]!),
                foregroundColor: Colors.grey[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
