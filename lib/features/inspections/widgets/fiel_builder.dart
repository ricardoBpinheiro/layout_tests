import 'package:flutter/material.dart';
import 'package:layout_tests/features/inspections/models/inspection_field.dart';

class FieldBuilder extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(width: 100.0, height: 100.0, color: Colors.amber);
  }
}
