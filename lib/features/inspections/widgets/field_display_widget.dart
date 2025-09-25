// Widget para exibir campo na etapa (similar ao Google Forms)
import 'package:flutter/material.dart';
import 'package:layout_tests/features/inspections/models/field_types.dart';
import 'package:layout_tests/features/inspections/models/inspection_field.dart';

class FieldDisplayWidget extends StatefulWidget {
  final InspectionField field;
  final int fieldIndex;
  final Function(InspectionField) onFieldUpdated;
  final VoidCallback onFieldDeleted;

  const FieldDisplayWidget({
    super.key,
    required this.field,
    required this.fieldIndex,
    required this.onFieldUpdated,
    required this.onFieldDeleted,
  });

  @override
  State<FieldDisplayWidget> createState() => _FieldDisplayWidgetState();
}

class _FieldDisplayWidgetState extends State<FieldDisplayWidget> {
  late TextEditingController _labelController;
  late TextEditingController _hintController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.field.label);
    _hintController = TextEditingController(text: widget.field.hint ?? '');
  }

  @override
  void dispose() {
    _labelController.dispose();
    _hintController.dispose();
    super.dispose();
  }

  void _updateField() {
    final updatedField = widget.field.copyWith(
      label: _labelController.text,
      hint: _hintController.text.isEmpty ? null : _hintController.text,
    );
    widget.onFieldUpdated(updatedField);
  }

  String _getFieldTypeDisplayName(FieldType type) {
    switch (type) {
      case FieldType.text:
        return 'Resposta em texto';
      case FieldType.number:
        return 'Número';
      case FieldType.email:
        return 'Email';
      case FieldType.phone:
        return 'Telefone';
      case FieldType.select:
        return 'Múltipla escolha';
      case FieldType.multiSelect:
        return 'Caixa de seleção';
      case FieldType.checkbox:
        return 'Sim/Não';
      case FieldType.photo:
        return 'Upload de arquivo';
      case FieldType.signature:
        return 'Assinatura';
      case FieldType.date:
        return 'Data';
      case FieldType.time:
        return 'Horário';
      case FieldType.rating:
        return 'Escala de avaliação';
      case FieldType.predefinedSet:
        throw UnimplementedError();
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
        return Icons.check_box_outlined;
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
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pergunta/Campo principal
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ícone de arrastar (drag handle)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Icon(
                  Icons.drag_indicator,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),

              // Conteúdo principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Campo de pergunta/label
                    TextFormField(
                      controller: _labelController,
                      onChanged: (_) => _updateField(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF202124),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Pergunta sem título',
                        border: InputBorder.none,
                        suffixIcon: widget.field.required
                            ? const Text(
                                ' *',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                ),
                              )
                            : null,
                        suffixIconConstraints: const BoxConstraints(
                          minWidth: 0,
                          minHeight: 0,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Preview do campo baseado no tipo
                    _buildFieldPreview(),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Barra de ferramentas inferior
          Row(
            children: [
              // Tipo de resposta
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getFieldTypeIcon(widget.field.type),
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getFieldTypeDisplayName(widget.field.type),
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Ações
              Row(
                children: [
                  // Botão duplicar
                  IconButton(
                    icon: Icon(
                      Icons.content_copy,
                      size: 18,
                      color: Colors.grey[600],
                    ),
                    onPressed: () {
                      // TODO: Implementar duplicação
                    },
                    tooltip: 'Duplicar',
                  ),

                  // Botão excluir
                  IconButton(
                    icon: Icon(Icons.delete, size: 18, color: Colors.grey[600]),
                    onPressed: widget.onFieldDeleted,
                    tooltip: 'Excluir',
                  ),

                  // Separador
                  Container(
                    height: 24,
                    width: 1,
                    color: Colors.grey[300],
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                  ),

                  // Toggle obrigatório
                  Row(
                    children: [
                      Text(
                        'Obrigatória',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                      Switch(
                        value: widget.field.required,
                        onChanged: (value) {
                          final updatedField = widget.field.copyWith(
                            required: value,
                          );
                          widget.onFieldUpdated(updatedField);
                        },
                        activeColor: const Color(0xFF4285f4),
                      ),
                    ],
                  ),

                  // Menu de opções
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 16),
                            SizedBox(width: 8),
                            Text('Editar opções'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'help',
                        child: Row(
                          children: [
                            Icon(Icons.help_outline, size: 16),
                            SizedBox(width: 8),
                            Text('Adicionar texto de ajuda'),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showFieldOptionsDialog();
                      } else if (value == 'help') {
                        _showHelpTextDialog();
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFieldPreview() {
    switch (widget.field.type) {
      case FieldType.text:
      case FieldType.number:
      case FieldType.email:
      case FieldType.phone:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFDADADA), width: 1),
            ),
          ),
          child: Text(
            widget.field.hint ?? 'Sua resposta',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        );

      case FieldType.select:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.field.options != null &&
                widget.field.options!.isNotEmpty)
              ...widget.field.options!.map((option) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.radio_button_unchecked,
                        size: 20,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(width: 12),
                      Text(option, style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                );
              })
            else
              Row(
                children: [
                  Icon(
                    Icons.radio_button_unchecked,
                    size: 20,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Opção 1',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
          ],
        );

      case FieldType.multiSelect:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.field.options != null &&
                widget.field.options!.isNotEmpty)
              ...widget.field.options!.map((option) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_box_outline_blank,
                        size: 20,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(width: 12),
                      Text(option, style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                );
              })
            else
              Row(
                children: [
                  Icon(
                    Icons.check_box_outline_blank,
                    size: 20,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Opção 1',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
          ],
        );

      case FieldType.checkbox:
        return Row(
          children: [
            Icon(
              Icons.check_box_outline_blank,
              size: 20,
              color: Colors.grey[400],
            ),
            const SizedBox(width: 12),
            Text(
              'Sim',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        );

      case FieldType.photo:
        return Container(
          height: 40,
          width: 120,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.file_upload, size: 16, color: Colors.grey[500]),
              const SizedBox(width: 8),
              Text(
                'Adicionar arquivo',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        );

      case FieldType.signature:
        return Container(
          height: 60,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.draw, size: 20, color: Colors.grey[500]),
                const SizedBox(width: 8),
                Text(
                  'Área de assinatura',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        );

      case FieldType.date:
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFDADADA), width: 1),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.event, size: 20, color: Colors.grey[500]),
              const SizedBox(width: 8),
              Text(
                'DD/MM/AAAA',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
            ],
          ),
        );

      case FieldType.time:
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFDADADA), width: 1),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.schedule, size: 20, color: Colors.grey[500]),
              const SizedBox(width: 8),
              Text(
                'HH:MM',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
            ],
          ),
        );

      case FieldType.rating:
        return Row(
          children: List.generate(5, (index) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(Icons.star_border, size: 24, color: Colors.grey[400]),
            );
          }),
        );
      case FieldType.predefinedSet:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  void _showFieldOptionsDialog() {
    // TODO: Implementar dialog para editar opções de múltipla escolha
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Opções'),
        content: const Text('Funcionalidade em desenvolvimento...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _showHelpTextDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Texto de Ajuda'),
        content: TextFormField(
          controller: _hintController,
          decoration: const InputDecoration(
            hintText: 'Digite o texto de ajuda...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              _updateField();
              Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}
