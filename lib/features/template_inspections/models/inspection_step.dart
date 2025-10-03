import 'package:layout_tests/features/template_inspections/models/inspection_field.dart';

class InspectionStep {
  final String id;
  final String name;
  final String description;
  final int order;
  final List<InspectionField> fields;

  InspectionStep({
    required this.id,
    required this.name,
    required this.description,
    required this.order,
    required this.fields,
  });

  InspectionStep copyWith({
    String? id,
    String? name,
    String? description,
    int? order,
    List<InspectionField>? fields,
  }) {
    return InspectionStep(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      order: order ?? this.order,
      fields: fields ?? this.fields,
    );
  }
}
