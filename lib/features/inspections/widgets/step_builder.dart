import 'package:flutter/material.dart';
import 'package:layout_tests/features/inspections/models/inspection_field.dart';
import 'package:layout_tests/features/inspections/models/inspection_step.dart';
import 'package:layout_tests/features/inspections/widgets/fiel_builder.dart';

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
  bool _isExpanded = true;

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
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Header da Etapa
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      '${widget.stepIndex + 1}',
                      style: const TextStyle(
                        color: Color(0xFF2563EB),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.step.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                  ),
                  onPressed: () => setState(() => _isExpanded = !_isExpanded),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: widget.onStepDeleted,
                ),
              ],
            ),
          ),

          // Conteúdo da Etapa (expansível)
          if (_isExpanded)
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nome da Etapa
                  TextFormField(
                    controller: _nameController,
                    onChanged: (_) => _updateStep(),
                    decoration: const InputDecoration(
                      labelText: 'Nome da Etapa',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Descrição da Etapa
                  TextFormField(
                    controller: _descriptionController,
                    onChanged: (_) => _updateStep(),
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Descrição (opcional)',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Campos da Etapa
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Campos',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: widget.onAddField,
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Adicionar Campo'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Lista de Campos
                  if (widget.step.fields.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.text_fields,
                            size: 32,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Nenhum campo adicionado',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...List.generate(widget.step.fields.length, (fieldIndex) {
                      final field = widget.step.fields[fieldIndex];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: FieldBuilder(
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
                          onFieldDeleted: () =>
                              widget.onRemoveField(fieldIndex),
                        ),
                      );
                    }),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
