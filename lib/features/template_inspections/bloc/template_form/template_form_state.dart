import '../../models/inspection_template.dart';

enum TemplateFormStatus { initial, loading, editing, saving, success, failure }

class TemplateFormState {
  final TemplateFormStatus status;
  final InspectionTemplate? template;
  final String? errorMessage;

  const TemplateFormState({
    this.status = TemplateFormStatus.initial,
    this.template,
    this.errorMessage,
  });

  TemplateFormState copyWith({
    TemplateFormStatus? status,
    InspectionTemplate? template,
    String? errorMessage,
  }) {
    return TemplateFormState(
      status: status ?? this.status,
      template: template ?? this.template,
      errorMessage: errorMessage,
    );
  }
}
