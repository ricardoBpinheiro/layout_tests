import 'package:layout_tests/features/inspections/models/field_option.dart';
import 'package:layout_tests/features/inspections/models/field_types.dart';
import 'package:layout_tests/features/inspections/models/question_rule.dart';

class InspectionField {
  final String id;
  final String label;
  final FieldType type;
  final bool required;
  final String? hint;
  final List<FieldOption>? options; // Para campos de seleção
  final String? validation; // Regex ou regra de validação
  final int order;
  final List<QuestionRule>? rules;

  InspectionField({
    required this.id,
    required this.label,
    required this.type,
    this.required = false,
    this.hint,
    this.options,
    this.validation,
    required this.order,
    this.rules,
  });

  InspectionField copyWith({
    String? id,
    String? label,
    FieldType? type,
    bool? required,
    String? hint,
    List<FieldOption>? options,
    String? validation,
    int? order,
    List<QuestionRule>? rules,
  }) {
    return InspectionField(
      id: id ?? this.id,
      label: label ?? this.label,
      type: type ?? this.type,
      required: required ?? this.required,
      hint: hint ?? this.hint,
      options: options ?? this.options,
      validation: validation ?? this.validation,
      order: order ?? this.order,
      rules: rules ?? this.rules,
    );
  }
}
