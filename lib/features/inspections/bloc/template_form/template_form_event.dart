import '../../models/inspection_field.dart';
import '../../models/question_rule.dart';

abstract class TemplateFormEvent {}

class TemplateFormStarted extends TemplateFormEvent {
  final String? templateId; // null = criar
  TemplateFormStarted({this.templateId});
}

class TemplateTitleChanged extends TemplateFormEvent {
  final String title;
  TemplateTitleChanged(this.title);
}

class TemplateDescriptionChanged extends TemplateFormEvent {
  final String description;
  TemplateDescriptionChanged(this.description);
}

// Operações na estrutura
class StepAdded extends TemplateFormEvent {}

class StepRemoved extends TemplateFormEvent {
  final int index;
  StepRemoved(this.index);
}

class SectionAdded extends TemplateFormEvent {
  final int stepIndex;
  SectionAdded(this.stepIndex);
}

class SectionRemoved extends TemplateFormEvent {
  final int stepIndex;
  final int sectionIndex;
  SectionRemoved(this.stepIndex, this.sectionIndex);
}

class FieldAdded extends TemplateFormEvent {
  final int stepIndex;
  final int sectionIndex;
  final InspectionField field;
  FieldAdded(this.stepIndex, this.sectionIndex, this.field);
}

class FieldUpdated extends TemplateFormEvent {
  final int stepIndex;
  final int sectionIndex;
  final int fieldIndex;
  final InspectionField field;
  FieldUpdated(this.stepIndex, this.sectionIndex, this.fieldIndex, this.field);
}

class FieldRemoved extends TemplateFormEvent {
  final int stepIndex;
  final int sectionIndex;
  final int fieldIndex;
  FieldRemoved(this.stepIndex, this.sectionIndex, this.fieldIndex);
}

class RuleAdded extends TemplateFormEvent {
  final int stepIndex;
  final int sectionIndex;
  final int fieldIndex;
  final QuestionRule rule;
  RuleAdded(this.stepIndex, this.sectionIndex, this.fieldIndex, this.rule);
}

class RuleRemoved extends TemplateFormEvent {
  final int stepIndex;
  final int sectionIndex;
  final int fieldIndex;
  final int ruleIndex;
  RuleRemoved(
    this.stepIndex,
    this.sectionIndex,
    this.fieldIndex,
    this.ruleIndex,
  );
}

class TemplateSaved extends TemplateFormEvent {}
