// Modelo para seção
import 'package:layout_tests/features/inspections/models/inspection_field.dart';

class InspectionSection {
  final String id;
  final String title;
  final String? description;
  final List<InspectionField> fields;
  final bool isCollapsed;

  InspectionSection({
    String? id,
    required this.title,
    this.description,
    List<InspectionField>? fields,
    this.isCollapsed = false,
  }) :
    id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
    fields = fields ?? [];

  InspectionSection copyWith({
    String? id,
    String? title,
    String? description,
    List<InspectionField>? fields,
    bool? isCollapsed,
  }) {
    return InspectionSection(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      fields: fields ?? this.fields,
      isCollapsed: isCollapsed ?? this.isCollapsed,
    );
  }
}
