import 'package:flutter/material.dart';
import 'package:layout_tests/features/template_inspections/models/field_types.dart';
import 'package:layout_tests/features/template_inspections/models/inspection_field.dart';

class FieldWidget extends StatelessWidget {
  final InspectionField field;
  final dynamic value;
  final Function(dynamic) onChanged;

  const FieldWidget({
    super.key,
    required this.field,
    this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    switch (field.type) {
      case FieldType.text:
        return Card(
          child: TextField(
            decoration: InputDecoration(
              labelText: field.label,
              hintText: field.hint,
            ),
            controller: TextEditingController(text: value ?? ''),
            onChanged: onChanged,
          ),
        );

      case FieldType.select:
        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                field.label,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Wrap(
                children: field.options!.map((opt) {
                  return ChoiceChip(
                    label: Text(opt.label),
                    selected: value == opt.id,
                    onSelected: (_) => onChanged(opt.id),
                  );
                }).toList(),
              ),
            ],
          ),
        );

      case FieldType.checkbox:
        return Card(
          child: CheckboxListTile(
            title: Text(field.label),
            value: value ?? false,
            onChanged: onChanged,
          ),
        );

      default:
        return Card(child: Text("Tipo não implementado: ${field.type}"));
    }
  }
}
