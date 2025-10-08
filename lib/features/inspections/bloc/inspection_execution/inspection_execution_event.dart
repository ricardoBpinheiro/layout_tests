import 'package:layout_tests/features/inspections/models/field_attachment.dart';
import 'package:layout_tests/features/template_inspections/models/inspection_field.dart';

abstract class InspectionExecutionEvent {}

class StartExecution extends InspectionExecutionEvent {}

class AnswerField extends InspectionExecutionEvent {
  final InspectionField field;
  final dynamic value;
  AnswerField(this.field, this.value);
}

class ChangeStep extends InspectionExecutionEvent {
  final int stepIndex;
  ChangeStep(this.stepIndex);
}

class NextStep extends InspectionExecutionEvent {}

class PreviousStep extends InspectionExecutionEvent {}

class SubmitInspection extends InspectionExecutionEvent {}

class SaveFieldNote extends InspectionExecutionEvent {
  final String fieldId;
  final String note;

  SaveFieldNote(this.fieldId, this.note);
}

class SaveDraftRequested extends InspectionExecutionEvent {}

class PerformSaveDraft extends InspectionExecutionEvent {}

class AddFieldAttachments extends InspectionExecutionEvent {
  final String fieldId;
  final List<FieldAttachment> attachments; // anexos a adicionar
  AddFieldAttachments(this.fieldId, this.attachments);
}

class RemoveFieldAttachmentAt extends InspectionExecutionEvent {
  final String fieldId;
  final int index;
  RemoveFieldAttachmentAt(this.fieldId, this.index);
}
