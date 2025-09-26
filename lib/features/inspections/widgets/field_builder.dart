import 'package:flutter/material.dart';
import 'package:layout_tests/features/inspections/models/field_types.dart';
import 'package:layout_tests/features/inspections/models/inspection_field.dart';

class FieldBuilder extends StatefulWidget {
  final InspectionField field;
  final int fieldIndex;
  final Function(InspectionField) onFieldUpdated;
  final VoidCallback onFieldDeleted;

  const FieldBuilder({
    super.key,
    required this.field,
    required this.fieldIndex,
    required this.onFieldUpdated,
    required this.onFieldDeleted,
  });

  @override
  State<FieldBuilder> createState() => _FieldBuilderState();
}

class _FieldBuilderState extends State<FieldBuilder> {
  late TextEditingController _labelController;
  late TextEditingController _hintController;
  late TextEditingController _optionsController;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.field.label);
    _hintController = TextEditingController(text: widget.field.hint ?? '');
    _optionsController = TextEditingController(
      text: widget.field.options?.join(', ') ?? '',
    );
  }

  @override
  void dispose() {
    _labelController.dispose();
    _hintController.dispose();
    _optionsController.dispose();
    super.dispose();
  }

  void _updateField() {
    List<String>? options;
    if (_needsOptions(widget.field.type) &&
        _optionsController.text.isNotEmpty) {
      options = _optionsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    final updatedField = widget.field.copyWith(
      label: _labelController.text,
      hint: _hintController.text.isEmpty ? null : _hintController.text,
      // options: options,
    );
    widget.onFieldUpdated(updatedField);
  }

  bool _needsOptions(FieldType type) {
    return type == FieldType.select || type == FieldType.multiSelect;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header do Campo
          Row(
            children: [
              Icon(
                getFieldTypeIcon(widget.field.type),
                size: 18,
                color: const Color(0xFF6B7280),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.field.label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  getFieldTypeDisplayName(widget.field.type),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF2563EB),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                onPressed: widget.onFieldDeleted,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Configurações do Campo
          Row(
            children: [
              // Nome do Campo
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _labelController,
                  onChanged: (_) => _updateField(),
                  decoration: const InputDecoration(
                    labelText: 'Nome do Campo',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    isDense: true,
                  ),
                  style: const TextStyle(fontSize: 12),
                ),
              ),

              const SizedBox(width: 12),

              // Tipo do Campo
              Expanded(
                child: DropdownButtonFormField<FieldType>(
                  value: widget.field.type,
                  decoration: const InputDecoration(
                    labelText: 'Tipo',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    isDense: true,
                  ),
                  style: const TextStyle(fontSize: 12, color: Colors.black),
                  items: FieldType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(
                        getFieldTypeDisplayName(type),
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  }).toList(),
                  onChanged: (newType) {
                    if (newType != null) {
                      final updatedField = widget.field.copyWith(
                        type: newType,
                        options: _needsOptions(newType) ? [] : null,
                      );
                      widget.onFieldUpdated(updatedField);
                    }
                  },
                ),
              ),

              const SizedBox(width: 12),

              // Obrigatório
              SizedBox(
                width: 100,
                child: CheckboxListTile(
                  value: widget.field.required,
                  onChanged: (required) {
                    final updatedField = widget.field.copyWith(
                      required: required,
                    );
                    widget.onFieldUpdated(updatedField);
                  },
                  title: const Text(
                    'Obrigatório',
                    style: TextStyle(fontSize: 10),
                  ),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  dense: true,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Hint Text
          TextFormField(
            controller: _hintController,
            onChanged: (_) => _updateField(),
            decoration: const InputDecoration(
              labelText: 'Texto de Ajuda (opcional)',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              isDense: true,
            ),
            style: const TextStyle(fontSize: 12),
          ),

          // Opções (para campos de seleção)
          if (_needsOptions(widget.field.type)) ...[
            const SizedBox(height: 12),
            TextFormField(
              controller: _optionsController,
              onChanged: (_) => _updateField(),
              decoration: const InputDecoration(
                labelText: 'Opções (separadas por vírgula)',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
                isDense: true,
                hintText: 'Ex: Opção 1, Opção 2, Opção 3',
              ),
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 8),
            if (widget.field.options != null &&
                widget.field.options!.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: widget.field.options!.map((option) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      option.label,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],

          // Preview do campo baseado no tipo
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.visibility, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      'Preview:',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildFieldPreview(),
              ],
            ),
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
        return SizedBox(
          height: 32,
          child: TextFormField(
            enabled: false,
            decoration: InputDecoration(
              labelText: widget.field.label,
              hintText: widget.field.hint,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              isDense: true,
              suffixIcon: widget.field.required
                  ? const Icon(Icons.star, size: 12, color: Colors.red)
                  : null,
            ),
            style: const TextStyle(fontSize: 12),
          ),
        );

      case FieldType.select:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.field.label + (widget.field.required ? ' *' : ''),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Text(
                    widget.field.hint ?? 'Selecione uma opção...',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_drop_down, size: 16),
                ],
              ),
            ),
          ],
        );

      case FieldType.multiSelect:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.field.label + (widget.field.required ? ' *' : ''),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            if (widget.field.options != null &&
                widget.field.options!.isNotEmpty)
              ...widget.field.options!.take(3).map((option) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[400]!),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(option.label, style: const TextStyle(fontSize: 11)),
                    ],
                  ),
                );
              }),
          ],
        );

      case FieldType.checkbox:
        return Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[400]!),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              widget.field.label + (widget.field.required ? ' *' : ''),
              style: const TextStyle(fontSize: 12),
            ),
          ],
        );

      case FieldType.photo:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.field.label + (widget.field.required ? ' *' : ''),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Container(
              height: 60,
              width: 80,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey[300]!,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, size: 20, color: Colors.grey[500]),
                  Text(
                    'Foto',
                    style: TextStyle(fontSize: 8, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ],
        );

      case FieldType.signature:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.field.label + (widget.field.required ? ' *' : ''),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Container(
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey[300]!,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.draw, size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    'Assinatura Digital',
                    style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ],
        );

      case FieldType.date:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.field.label + (widget.field.required ? ' *' : ''),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Text(
                    'DD/MM/AAAA',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  const Spacer(),
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[500]),
                ],
              ),
            ),
          ],
        );

      case FieldType.time:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.field.label + (widget.field.required ? ' *' : ''),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Text(
                    'HH:MM',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  const Spacer(),
                  Icon(Icons.access_time, size: 16, color: Colors.grey[500]),
                ],
              ),
            ),
          ],
        );

      case FieldType.rating:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.field.label + (widget.field.required ? ' *' : ''),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  Icons.star_border,
                  size: 16,
                  color: Colors.grey[400],
                );
              }),
            ),
          ],
        );
      case FieldType.predefinedSet:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
}
